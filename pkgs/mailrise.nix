{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "mailrise";
  version = "1.4.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BKl5g4R9L5IrygMd9Vbi20iF2APpxSSfKxU25naPGTc=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiosmtpd
    apprise
    pyyaml
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    testing = [
      pytest
      pytest-asyncio
      pytest-cov
      setuptools
      types-pyyaml
    ];
  };

  pythonImportsCheck = ["mailrise"];

  meta = with lib; {
    description = "An SMTP gateway for Apprise notifications";
    homepage = "https://pypi.org/project/mailrise/";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "mailrise";
  };
}
