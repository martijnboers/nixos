{
  lib,
  rustPlatform,
  fetchFromGitLab,
  dbus,
  pkg-config,
  openssl,
  gtk4,
}:

rustPlatform.buildRustPackage {
  pname = "bw-keyring-daemon";
  version = "master";

  src = fetchFromGitLab {
    owner = "rbocquillon";
    repo = "bw-keyring-daemon";
    rev = "f1495126f6f1362350f51df80f07fabb65db60b8";
    hash = "sha256-1TAX7eQucOjPlb6vHfIysDgjFQIAy8TJk+EK1jCd+PU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    gtk4
    openssl
  ];

  cargoHash = "sha256-L1X0819OyRVW+hiHoitkaNylxM09RgYQFiTl+F/pMuA=";

  meta = {
    description = "Bitwarden secret service";
    homepage = "https://gitlab.com/rbocquillon/bw-keyring-daemon/";
    license = lib.licenses.gpl3;
    mainProgram = "bw_keyring_daemon";
    platforms = lib.platforms.linux;
  };
}
