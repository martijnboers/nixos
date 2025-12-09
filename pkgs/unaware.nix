{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "unaware";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "unaware";
    rev = version;
    hash = "sha256-YalEiC2NsUYefY+AZNgoADaRIas3+OQSJGRx620zDoE=";
  };

  vendorHash = "sha256-fU5X8yh2+xB/xNknyoJAYt2EyCsRzCV8tYbDY5R1KUk=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Mask PII-data offline";
    homepage = "https://github.com/martijnboers/unaware";
    license = licenses.mpl20;
    mainProgram = "unaware";
  };
}
