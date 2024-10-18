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
    owner = "martijnboers";
    repo = "tormon";
    rev = version;
    hash = "sha256-niWSvmO6lp0XQ18lC8hB9qvcuGDQv0U7ZO/Nfn8zXWY=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    influxdb
    stem
  ];

  pythonImportsCheck = [
    "exporter"
  ];

  meta = {
    description = "Monitor Tor relay with Grafana";
    homepage = "https://github.com/martijnboers/tormon";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "application";
  };
}
