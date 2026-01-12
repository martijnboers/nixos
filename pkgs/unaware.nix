{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "unaware";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "unaware";
    rev = version;
    hash = "sha256-Sm5qJ+ZMIfN0MoAfv6kkHN50D9CvC/brN3lzzVE1fh4=";
  };

  vendorHash = "sha256-j1OpJfz0yi2xaD7QzXp9sFgkRWUpv77oWCSCJIVC5iA=";

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
