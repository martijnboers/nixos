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
    rev = "65d05627e60b9884ba2fc969874c75ec360e1aa0";
    hash = "sha256-zsqPnT5ckl05OnL4wd5NMqd5okjggHfs4SDxDNIVLWY=";
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
