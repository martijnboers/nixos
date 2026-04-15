{
  lib,
  pkgs,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "stalwart";
  version = pkgs.stalwart.version;

  # See for defaults: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/st/stalwart/package.nix

  src = pkgs.stalwart.src;

  # Copy necessary attributes from original package
  nativeBuildInputs = pkgs.stalwart.nativeBuildInputs;
  buildInputs = pkgs.stalwart.buildInputs;
  depsBuildBuild = pkgs.stalwart.depsBuildBuild or [ ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "postgres"
    "s3"
    "zenoh"
  ];

  cargoHash = "sha256-WneUROKV+uLX1d5TIOanO0jhHLsHHpFcXKUB6zdbSzA=";

  # Environment variables needed for the build
  OPENSSL_NO_VENDOR = true;
  ZSTD_SYS_USE_PKG_CONFIG = true;

  # Disable LTO for faster build
  cargoLtoMode = null;
  doCheck = false;

  # Copy postInstall from original
  postInstall = ''
    mkdir -p $out/etc/stalwart
    mkdir -p $out/lib/systemd/system
    substitute resources/systemd/stalwart-mail.service $out/lib/systemd/system/stalwart.service \
      --replace-fail "__PATH__" "$out"
  '';
  meta = pkgs.stalwart.meta;
}
