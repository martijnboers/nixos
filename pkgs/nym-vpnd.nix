{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  protobuf,
  nym-libwg,
  cacert,
  dbus,
  libmnl,
  libnftnl,
}:

rustPlatform.buildRustPackage {
  pname = "nym-vpnd";
  version = "1.25.0-beta";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "nym-vpn-client";
    rev = "refs/heads/develop";
    sha256 = "sha256-4XLIgXOUZRhcpce467eKXouuG0AtWCi+pAL9g9pMHJQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-4MUbi4Idz/xIzhHzBhgOw/i+vLO8Ridijtvc1QmE+lY=";
  sourceRoot = "source/nym-vpn-core";

  cargoBuildFlags = [ "--release" ];
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];
  buildInputs = [
    nym-libwg
    cacert
    dbus
    libmnl
    libnftnl
  ];

  # Fix for nym-network-defaults build.rs failing in sandbox
  preBuild = ''
    # Patch nym-network-defaults build.rs to skip cargo metadata and env file writes
    find ../.. -name "build.rs" | grep nym-network-defaults | while read f; do
      chmod +w "$f"
      echo 'fn main() {}' > "$f"
    done

    # Prepare libwg location for nym-wg-go/build.rs
    # It expects it in $BUILD_TOP/build/lib/$TARGET
    mkdir -p build/lib/${stdenv.hostPlatform.config}
    cp ${nym-libwg}/lib/${stdenv.hostPlatform.config}/libwg.a build/lib/${stdenv.hostPlatform.config}/
    export BUILD_TOP=$(pwd)
  '';

  # cut targets to minimal binaries -> build nym-vpnd + nym-vpnc
  buildPhase = ''
    runHook preBuild
    export RUSTFLAGS="${lib.optionalString stdenv.hostPlatform.isMusl "-C link-arg=-Wl,--no-export-dynamic"}"
    # build both binaries
    cargo build --release -p nym-vpnd -p nym-vpnc
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/nym-vpnd $out/bin/
    cp target/release/nym-vpnc $out/bin/
  '';

  meta = with lib; {
    description = "NymVPN daemon + CLI (local build, amnezia enabled)";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
