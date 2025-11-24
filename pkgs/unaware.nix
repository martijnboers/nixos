{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "unaware";
  version = "main";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "unaware";
    rev = version;
    hash = "sha256-ubp7BTl9cXfzbRImNxc8Kzd8/wrINhlr1eCaSw3F4jU=";
  };

  vendorHash = "sha256-2a8yqHzFwg5rgFYeXLul2dCyXBWJkbkKrvxXyeiX63U=";

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
