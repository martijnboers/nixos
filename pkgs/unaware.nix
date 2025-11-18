{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "unaware";
  version = "master";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "unaware";
    rev = "master";
    hash = "sha256-ahyywQ9f4dLUriRpsyVX1HBcRCk1UhyDYvsYW9qqP5s=";
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
