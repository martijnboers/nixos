{
  rustPlatform,
  fetchFromGitHub,
  pkgs,
}:
rustPlatform.buildRustPackage rec {
  pname = "rustfs";
  version = "1.0.0-alpha.76";

  src = fetchFromGitHub {
    owner = "rustfs";
    repo = "rustfs";
    rev = version;
    hash = "sha256-b99jjug8ZUXoe2Hh+gbrODzQJi9wmR0PPT57aEyi6OY=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    protobuf
  ];

  cargoHash = "sha256-tEbeP6RI858JSLLROgBubQEUwHMID4lfpWReJt6vC5k=";
  buildInputs = with pkgs; [ openssl ];

  cargoBuildFlags = [
    "--package"
    "rustfs"
  ];

  doCheck = false;

  meta = {
    description = "High-performance S3-compatible object storage";
    homepage = "https://rustfs.com";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "rustfs";
  };
}
