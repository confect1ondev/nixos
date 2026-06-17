{ config, pkgs, lib, ... }:

# Hyprlock "x-prefix" unlock trick:
# Typing `x` before your password closes every Hyprland window before unlock for security/privacy.
# The leading `x` is stripped from PAM_AUTHTOK so pam_unix still sees your real password.
#
# Implementation: a small custom PAM module (pam_hypr_x.so) sits in front of
# `auth include login` in the hyprlock PAM stack. pam_exec can't rewrite the
# authtok mid-stack, so a real module is the cleanest path.
let
  hypr-close-helper = pkgs.writeShellScriptBin "hypr-close-helper" ''
    set -u
    if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      HYPR_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr"
      if [ -d "$HYPR_DIR" ]; then
        HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$HYPR_DIR" 2>/dev/null | head -n1 || true)"
        export HYPRLAND_INSTANCE_SIGNATURE
      fi
    fi
    [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || exit 0

    ${pkgs.hyprland}/bin/hyprctl clients -j 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.[].address' \
      | while IFS= read -r addr; do
          [ -n "$addr" ] || continue
          ${pkgs.hyprland}/bin/hyprctl dispatch closewindow "address:$addr" >/dev/null 2>&1 || true
        done
  '';

  pam-hypr-x = pkgs.stdenv.mkDerivation {
    pname = "pam-hypr-x";
    version = "1.0";

    dontUnpack = true;
    buildInputs = [ pkgs.pam ];

    src = pkgs.writeText "pam_hypr_x.c" ''
      #define _GNU_SOURCE
      #include <security/pam_modules.h>
      #include <security/pam_ext.h>
      #include <string.h>
      #include <stdlib.h>
      #include <unistd.h>
      #include <sys/wait.h>
      #include <sys/types.h>

      int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
          (void)flags;
          const char *authtok = NULL;
          int rv = pam_get_authtok(pamh, PAM_AUTHTOK, &authtok, NULL);
          if (rv != PAM_SUCCESS || authtok == NULL || authtok[0] != 'x') {
              return PAM_IGNORE;
          }

          if (argc > 0 && argv[0] != NULL) {
              pid_t pid = fork();
              if (pid == 0) {
                  execl(argv[0], argv[0], (char *)NULL);
                  _exit(127);
              } else if (pid > 0) {
                  int status;
                  waitpid(pid, &status, 0);
              }
          }

          size_t len = strlen(authtok);
          char *stripped = malloc(len);
          if (!stripped) return PAM_IGNORE;
          memcpy(stripped, authtok + 1, len);

          pam_set_item(pamh, PAM_AUTHTOK, stripped);

          memset(stripped, 0, len);
          free(stripped);

          return PAM_IGNORE;
      }

      int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
          (void)pamh; (void)flags; (void)argc; (void)argv;
          return PAM_IGNORE;
      }
    '';

    buildPhase = ''
      runHook preBuild
      cp $src pam_hypr_x.c
      $CC -shared -fPIC -Wall -O2 -o pam_hypr_x.so pam_hypr_x.c -lpam
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/security
      cp pam_hypr_x.so $out/lib/security/
      runHook postInstall
    '';
  };
in
{
  security.pam.services.hyprlock.text = lib.mkForce ''
    auth optional ${pam-hypr-x}/lib/security/pam_hypr_x.so ${hypr-close-helper}/bin/hypr-close-helper
    auth include login
  '';
}
