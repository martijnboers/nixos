{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule rec {
  pname = "smtp-gotify";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jreiml";
    repo = "smtp-gotify";
    rev = "main";
    # nix-prefetch-git --url https://github.com/jreiml/smtp-gotify
    hash = "sha256-BVIv5DeMrI4d4ka3plXkJYH+ow8Nks/NDqYw/TRhVqI=";
  };

  vendorHash = "sha256-tk4mpiRRRrgzBJ1WuBznbXUYVqqIZ7dxFskAV8loPqw=";

  nativeBuildInputs = [ git ];

  preBuild = ''
    export SG_VERSION=$(git describe --tags --always)
    echo "Embedding version: $SG_VERSION"

    # This is the `sed` command from the Dockerfile
    sed -i "s/UNKNOWN_RELEASE/$SG_VERSION/g" smtp-gotify.go
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A small SMTP server that forwards emails to a Gotify server";
    homepage = "https://github.com/jreiml/smtp-gotify";
    license = licenses.mit; # The repo contains an MIT license
    maintainers = with maintainers; [ ]; # Add your handle here if you maintain this package
    platforms = platforms.linux;
  };
}
