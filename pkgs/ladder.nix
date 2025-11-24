{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "ladder";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "everywall";
    repo = "ladder";
    rev = "v${version}";
    hash = "sha256-9KL9ghQFyU+8UyPVAfrf/9J24OUDyiUXVXaSqZ8P3/o=";
  };

  postPatch = ''
    echo "v${version}" >handlers/VERSION
  '';

  vendorHash = "sha256-LnbmWpKJo7USTcl5RQknw3nGe4YZ7iNWnl/dtT43afk=";

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/ladder
  '';

  meta = with lib; {
    description = "Alternative to 12ft.io. Bypass paywalls with a proxy ladder and remove CORS headers from any URL";
    homepage = "https://github.com/kubero-dev/ladder";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ jpetrucciani ];
    mainProgram = "ladder";
  };
}
