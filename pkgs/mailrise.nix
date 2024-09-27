{
  lib,
  fetchPypi,
  python3,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "mailrise";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BKl5g4R9L5IrygMd9Vbi20iF2APpxSSfKxU25naPGTc=";
  };

  doCheck = false;
  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
    aiosmtpd
    apprise
    packaging
    setuptools # No module named 'pkg_resources'
  ];

  meta = with lib; {
    description = "An SMTP gateway for Apprise notifications.";
    homepage = "https://github.com/YoRyan/mailrise";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "mailrise";
  };
}
