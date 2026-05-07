{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "exporter";
  version = "master";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "noisesfromspace";
    repo = "tormon";
    rev = version;
    hash = "sha256-iizvGP/Nf07iT8MFObiOXjDZC2fonBLJOoFrR8drPnI=";
  };

  build-system = [
    python3.pkgs.uv
  ];

  meta = {
    description = "Monitor Tor relay with Grafana";
    homepage = "https://github.com/noisesfromspace/tormon";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "application";
  };
}
