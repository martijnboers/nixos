{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  oniguruma,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flowmark-rs";
  version = "0.2.6";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jlevy";
    repo = "flowmark-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EhleyD/HfRNvAX6mPDlPflTEH5IwATFzF++TXsbSOv4=";
  };

  cargoHash = "sha256-0jfRYZ/YypA9eJKFB44m2JqrRVifThykzcgqZtAaBbY=";

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    oniguruma
  ];

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern Markdown formatter with smart typography, line wrapping, and tag support (Rust port";
    homepage = "https://github.com/jlevy/flowmark-rs";
    changelog = "https://github.com/jlevy/flowmark-rs/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "flowmark-rs";
  };
})
