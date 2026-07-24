{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonApplication rec {
  pname = "claude-monitor";
  version = "4.0.0";
  pyproject = true;

  src = fetchPypi {
    pname = "claude_monitor";
    inherit version;
    sha256 = "e5f15489f388c75deb2249abe35e0db4b6c67baa53a82dffbbf95d6957cfec76";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    numpy
    pydantic
    pydantic-settings
    pyyaml
    pytz
    rich
    wcwidth
  ];

  doCheck = false;

  meta = {
    description = "Real-time Claude Code usage monitor (TUI)";
    homepage = "https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor";
    license = lib.licenses.mit;
    mainProgram = "claude-monitor";
  };
}
