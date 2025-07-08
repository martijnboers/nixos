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

  # This is the Go module's hash.
  # If the upstream project changes go.mod/go.sum, this will need to be updated.
  # To find this, set it to lib.fakeSha256, build, and copy the hash from the error.
  vendorSha256 = "sha256-7R3Z9YfS3z4qY3376B1uWq+bC/B++xTmo3q8V+Vp2jI=";

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

  CGO_ENABLED = 0;

  meta = with lib; {
    description = "A small SMTP server that forwards emails to a Gotify server";
    homepage = "https://github.com/jreiml/smtp-gotify";
    license = licenses.mit; # The repo contains an MIT license
    maintainers = with maintainers; [ ]; # Add your handle here if you maintain this package
    platforms = platforms.linux;
  };
}
