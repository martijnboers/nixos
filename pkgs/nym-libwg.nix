{
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  libmnl,
  libnftnl,
}:

buildGoModule {
  pname = "nym-libwg";
  version = "1.29.2";

  src = fetchFromGitHub {
    owner = "nymtech";
    repo = "nym-vpn-client";
    rev = "431bbf27920864e17f3d2179e3a9d74e68316927";
    sha256 = "sha256-JDlhZswuUVURJ5TyvdGtcdUm/4l4kPXGGyQKQOek/xM=";
    fetchSubmodules = true;
  };

  modRoot = "wireguard/libwg";
  proxyVendor = true;
  vendorHash = "sha256-gpsbt3n2ogwmffFJwnBJXRE/M4uMR/nGx+ppMMeXTI0=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libmnl
    libnftnl
  ];

  buildPhase = ''
    runHook preBuild
    # modRoot is wireguard/libwg. buildGoModule is already there.
    export GOCACHE=$TMPDIR/go-cache
    # Nix buildGoModule has prepared the vendor directory.
    # We run the build manually to ensure it uses the right flags and output path.
    mkdir -p ../../build/lib/x86_64-unknown-linux-gnu
    go build -ldflags="-buildid=" -trimpath -buildvcs=false -v \
      -o ../../build/lib/x86_64-unknown-linux-gnu/libwg.a \
      -buildmode c-archive .
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r ../../build/lib/* $out/lib/
    if [ -d ../include ]; then
      mkdir -p $out/include
      cp -r ../include/* $out/include/
    fi
  '';
}
