# secrets/secrets.nix
let
  bootstrapKey = builtins.readFile ./bootstrap_agenix_key.pub;
in {
  "confect1on-password.age".publicKeys = [ bootstrapKey ];
}
