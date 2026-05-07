{
  rustPlatform,
  pkg-config,
  notmuch,
  pkgs,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.1.0";

  src = pkgs.fetchFromRadicle {
    seed = "seed.boers.email";
    repo = "z2AdUML1AaZmUVidUJ4vwQDJhmvKg";
    rev = "fb72f998b18d7c38a85d4e5b89af3e34ce5ff9e9";
    hash = "sha256-OpqkIQYYOdsjV5FkVL3LvQ1tL2WV+Agtk9YX7bUqAWo=";
  };

  cargoHash = "sha256-kb8VxlFf6oNbi0x8gkWSVJ+OHr9sMUYN9IQ55o2fxT8=";

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
