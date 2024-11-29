{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
  writeText,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "smtp-to-storage";
  version = "1";
  src = ./.;
  propagatedBuildInputs = with python3Packages; [aiosmtpd];
  meta = {
    mainProgram = "main.py";
  };
}
