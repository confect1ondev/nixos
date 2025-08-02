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
PORT = 8086

# Read the font file and encode it as base64
def get_font_data():
    font_path = "styles/Hack.ttf"
    if os.path.exists(font_path):
        with open(font_path, "rb") as f:
            return base64.b64encode(f.read()).decode('utf-8')
    return ""

# Embedded CSS (colors + styles combined)
def get_embedded_css(font_data):
    return f"""
:root {{
    /* Special */
    --background: #000000;
    --foreground: #c5c5c5;
    --cursor: #c5c5c5;

    /* Colors */
    --color0: #000000;
    --color1: #383a3d;
    --color2: #3c3e42;
    --color3: #001170;
    --color4: #00076b;
    --color5: #002397;
    --color6: #3855b3;
    --color7: #c5c5c5;
    --color8: #515152;
    --color9: #525458;
    --color10: #434549;
    --color11: #020064;
    --color12: #0012b6;
    --color15: #c5c5c5;
}}

@font-face {{
    font-family: "Roboto Mono";
    src: url("data:font/truetype;base64,{font_data}");
}}

:root {{
    --font: "Roboto Mono";
    --branch: 1px solid var(--color12);
}}

html {{
    font-size: 24px;
}}

body {{
    background: var(--background);
}}

.container {{
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}}

.prompt {{
    font-family: var(--font);
    color: var(--color5);
}}

.prompt~.prompt {{
    padding: 1.5rem 0 0.3125rem;
}}

span {{
    color: var(--color10);
}}

h1 {{
    display: inline;
    font-family: var(--font);
    font-size: 1rem;
    font-weight: normal;
    color: var(--color9);
}}

.tree > ul {{
    margin: 0;
    padding-left: 1rem;
    padding-right: 1rem;
}}

ul {{
    list-style: none;
    padding-left: 2.5rem;
    white-space:nowrap;
}}

li {{
    position: relative;
}}

li::before, li::after {{
    content: "";
    position: absolute;
    left: -0.75rem;
}}

li::before {{
    border-top: var(--branch);
    top: 0.75rem;
    width: 0.5rem;
}}

li::after {{
    border-left: var(--branch);
    height: 100%;
    top: 0.25rem;
}}

li:last-child::after {{
    height: 0.5rem;
}}

a {{
    font-family: var(--font);
    font-size: 1rem;
    color: var(--color6);
    text-decoration: none;
    outline: none;
}}

a:hover {{
    color: var(--color12);
    background: var(--background);
}}

form h1 {{
    padding-left: 0.125rem;
}}

input {{
    font-family: var(--font);
    font-size: 1rem;
    color: var(--color6);
    background-color: var(--background);
    border-width: 1px;
    border-color: var(--color12);
    border-style: solid;
    padding-top: 4px;
    padding-bottom: 4px;
}}

.row {{
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}}

.column {{
    flex: 1;
    min-width: 250px;
    padding: 5px;
}}

.row:after {{
    content: "";
    display: table;
    clear: both;
}}
"""

# Embedded HTML
HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
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
                <li><a href="https://chat.openai.com/">chatgpt</a></li>
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

      <!-- System Section -->
      <div class="column">
        <div class="tree">
          <h1>.</h1>
          <ul>
            <li>
              <h1>system</h1>
              <ul>
                <li><a href="http://localhost:11987/">coolercontrol</a></li>
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
            # Get font data and inject into CSS
            font_data = get_font_data()
            css_content = get_embedded_css(font_data)
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