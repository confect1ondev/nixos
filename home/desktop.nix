{ config, pkgs, my, ... }:

{
  # GTK theme configuration
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "GoogleDot-Blue";
      size = 24;
      package = pkgs.google-cursor;
    };
  };

  # StartTree systemd service with embedded server
  # This is heavily inspired by, and initially based off of Paul Houser's StartTree project (https://github.com/Paul-Houser/StartTree)
  systemd.user.services.starttree = {
    Unit = {
      Description = "StartTree startpage server";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = let
        startTreeScript = pkgs.writeText "starttree-server.py" ''
          #!/usr/bin/env python3
          """
          Self-contained startpage server with embedded HTML and CSS
          """
          
          import http.server
          import socketserver
          import base64
          import os
          import sys
          
          # Port to serve on
          PORT = ${toString my.ports.starttree}
          
          # Embedded CSS (colors + styles combined)
          def get_embedded_css():
              return """
          :root {
              /* Background and Base Colors - matching Hyprland theme */
              --background: #0a0e14;
              --foreground: #b3b1ad;
              --cursor: #b3b1ad;
          
              /* Accent Colors - blue theme matching waybar */
              --accent-primary: #59c2ff;
              --accent-secondary: #39bae6;
              --accent-dim: #0d1016;
              
              /* Text Colors */
              --text-primary: #b3b1ad;
              --text-secondary: #626a73;
              --text-bright: #e6e1cf;
              
              /* UI Colors */
              --border-color: #39bae6;
              --hover-bg: #0d1016;
              --input-bg: #0d1016;
              
              /* Font Stack */
              --font: "JetBrainsMono Nerd Font", "JetBrains Mono", "Hack", "DejaVu Sans Mono", "Consolas", monospace;
              --branch: 2px solid var(--border-color);
          }
          
          html {
              font-size: 20px;
          }
          
          @media (min-width: 1600px) {
              html {
                  font-size: 22px;
              }
          }
          
          @media (min-width: 2000px) {
              html {
                  font-size: 24px;
              }
          }
          
          body {
              background: var(--background);
              color: var(--foreground);
              font-family: var(--font);
              margin: 0;
              padding: 0;
              min-height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
          }
          
          .container {
              width: 85%;
              max-width: 1400px;
              padding: 3rem;
              background: rgba(13, 16, 22, 0.5);
              border: 1px solid var(--border-color);
              border-radius: 8px;
              backdrop-filter: blur(10px);
              box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
          }
          
          @media (max-width: 1200px) {
              .container {
                  width: 80%;
              }
          }
          
          .prompt {
              font-family: var(--font);
              color: var(--accent-primary);
              font-weight: bold;
              margin-bottom: 1rem;
          }
          
          .prompt~.prompt {
              padding: 1.5rem 0 0.5rem;
          }
          
          span {
              color: var(--accent-secondary);
          }
          
          h1 {
              display: inline;
              font-family: var(--font);
              font-size: 1rem;
              font-weight: 600;
              color: var(--text-bright);
          }
          
          .tree > ul {
              margin: 0;
              padding-left: 1rem;
              padding-right: 1rem;
          }
          
          ul {
              list-style: none;
              padding-left: 2.5rem;
              white-space:nowrap;
          }
          
          li {
              position: relative;
          }
          
          li::before, li::after {
              content: "";
              position: absolute;
              left: -0.75rem;
          }
          
          li::before {
              border-top: var(--branch);
              top: 0.75rem;
              width: 0.5rem;
          }
          
          li::after {
              border-left: var(--branch);
              height: 100%;
              top: 0.25rem;
          }
          
          li:last-child::after {
              height: 0.5rem;
          }
          
          a {
              font-family: var(--font);
              font-size: 0.9rem;
              color: var(--accent-primary);
              text-decoration: none;
              outline: none;
              transition: all 0.2s ease;
              padding: 2px 6px;
              border-radius: 4px;
          }
          
          a:hover {
              color: var(--text-bright);
              background: var(--hover-bg);
              box-shadow: 0 0 0 1px var(--border-color);
          }
          
          form {
              margin-top: 2rem;
          }
          
          form h1 {
              padding-left: 0.125rem;
              margin-right: 0.5rem;
          }
          
          input {
              font-family: var(--font);
              font-size: 0.9rem;
              color: var(--text-bright);
              background-color: var(--input-bg);
              border: 2px solid var(--border-color);
              border-radius: 4px;
              padding: 8px 12px;
              width: 300px;
              transition: all 0.2s ease;
          }
          
          input:focus {
              outline: none;
              border-color: var(--accent-primary);
              box-shadow: 0 0 0 3px rgba(89, 194, 255, 0.2);
          }
          
          .row {
              display: flex;
              flex-wrap: wrap;
              gap: 2rem;
              justify-content: space-evenly;
              align-items: flex-start;
          }
          
          .column {
              flex: 1 1 300px;
              max-width: 400px;
              padding: 10px;
          }
          
          /* Only go vertical on very narrow screens */
          @media (max-width: 600px) {
              .row {
                  flex-direction: column;
                  align-items: center;
              }
              
              .column {
                  max-width: 100%;
              }
              
              input {
                  width: 100%;
              }
          }
          """
          
          # Embedded HTML
          HTML_TEMPLATE = """<!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8"/>
            <meta name="darkreader-lock" content="true"/>
            <title>Home</title>
            <style>
          {css}
            </style>
          </head>
          <body>
            <div class="container">
              <div class="prompt">
                ~ <span>λ</span> tree
              </div>
          
              <div class="row">
                <!-- General Section -->
                <div class="column">
                  <div class="tree">
                    <h1>.</h1>
                    <ul>
                      <li>
                        <h1>general</h1>
                        <ul>
                          <li><a href="https://discord.com/channels/@me/">discord</a></li>
                          <li><a href="https://www.youtube.com/">youtube</a></li>
                          <li><a href="https://www.amazon.com/">amazon</a></li>
                          <li><a href="https://www.github.com/">github</a></li>
                          <li><a href="https://www.reddit.com/">reddit</a></li>
                          <li><a href="https://roarcommunity.circle.so/">roar</a></li>
                        </ul>
                      </li>
                    </ul>
                  </div>
                </div>
          
                <!-- Productivity Section -->
                <div class="column">
                  <div class="tree">
                    <h1>.</h1>
                    <ul>
                      <li>
                        <h1>productivity</h1>
                        <ul>
                          <li><a href="https://claude.ai/">claude</a></li>
                          <li><a href="https://mail.google.com/">gmail</a></li>
                          <li>
                            <a href="https://drive.google.com/">google drive</a>
                            <ul>
                              <li><a href="https://docs.google.com/">google docs</a></li>
                              <li><a href="https://sheets.google.com/">google sheets</a></li>
                            </ul>
                          </li>
                        </ul>
                      </li>
                    </ul>
                  </div>
                </div>
          
                <!-- Finances Section -->
                <div class="column">
                  <div class="tree">
                    <h1>.</h1>
                    <ul>
                      <li>
                        <h1><a href="https://docs.google.com/spreadsheets/d/1tcY8v7KG_0GTx6lXZp2VKe7yLFEzzLY0YNE5_b6dCqo">finances</a></h1>
                        <ul>
                          <li>
                            <h1>investments</h1>
                            <ul>
                              <li><a href="https://client.schwab.com/Areas/Access/Login">schwab</a></li>
                              <li><a href="https://digital.fidelity.com/prgw/digital/login/full-page">fidelity</a></li>
                            </ul>
                          </li>
                          <li>
                            <h1>banking</h1>
                            <ul>
                              <li><a href="https://www.americanexpress.com/en-us/account/login">american express</a></li>
                              <li><a href="https://onlinebanking.usbank.com/auth/login/">us bank</a></li>
                              <li><a href="https://www.chase.com/">chase</a></li>
                              <li><a href="https://app.koinly.io/login/">koinly</a></li>
                            </ul>
                          </li>
                        </ul>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
          
              <!-- Search Bar -->
              <div class="prompt">
                ~ <span>λ</span> google
              </div>
              <form action="https://www.google.com/search" method="GET">
                <h1>search:</h1>
                <input autofocus="autofocus" name="q" type="text"/>
              </form>
            </div>
          </body>
          </html>"""
          
          class StartPageHandler(http.server.SimpleHTTPRequestHandler):
              def do_GET(self):
                  if self.path == '/' or self.path == '/index.html':
                      css_content = get_embedded_css()
                      html_content = HTML_TEMPLATE.format(css=css_content)
                      
                      self.send_response(200)
                      self.send_header('Content-type', 'text/html')
                      self.end_headers()
                      self.wfile.write(html_content.encode('utf-8'))
                  else:
                      self.send_error(404)
          
          def main():
              try:
                  with socketserver.TCPServer(("", PORT), StartPageHandler) as httpd:
                      print(f"Serving startpage at http://localhost:{PORT}")
                      print("Press Ctrl+C to stop the server")
                      httpd.serve_forever()
              except KeyboardInterrupt:
                  print("\nServer stopped.")
              except OSError as e:
                  if e.errno == 98:  # Address already in use
                      print(f"Port {PORT} is already in use. Try a different port.")
                  else:
                      print(f"Error starting server: {e}")
                  sys.exit(1)
          
          if __name__ == "__main__":
              main()
        '';
      in "${pkgs.python3}/bin/python3 ${startTreeScript}";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}