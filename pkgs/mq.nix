{
  rustPlatform,
  pkg-config,
  notmuch,
  pkgs,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://seed.boers.email/z2AdUML1AaZmUVidUJ4vwQDJhmvKg.git";
    rev = "9ee96b7fb7b747be1e957f8c059540c486739cb5";
    hash = "sha256-KA85DXZDuNdL/UkEbgxCCBW+Ft0xb+hUFd5HL1Pw5ag=";
  };

  cargoHash = "sha256-Cu4JlPFPoJ2pndsPrrhSY8Hy4PFodVjDol41ng0UtaE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    notmuch
  ];

  meta = {
    description = "A fast, read-only notmuch email search TUI designed to complement aerc and mutt.";
    mainProgram = "mq";
  };
}
