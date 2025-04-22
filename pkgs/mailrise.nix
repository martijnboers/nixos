{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "mailrise";
  version = "1.4.0";
  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BKl5g4R9L5IrygMd9Vbi20iF2APpxSSfKxU25naPGTc=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    aiosmtpd
    apprise
    pyyaml
    setuptools
    setuptools-scm
  ];

  pythonImportsCheck = [ "mailrise" ];

  meta = with lib; {
    description = "An SMTP gateway for Apprise notifications";
    homepage = "https://pypi.org/project/mailrise/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "mailrise";
  };
}
