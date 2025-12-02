{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # prev = unaltered (before overlays)
  # final = after overlay mods, like rec keyword
  modifications = final: prev: {
    # strawberry = prev.strawberry.overrideAttrs (oldAttrs: {
    #   # Set the flags to prevent stripping
    #   dontStrip = true;
    #   dontPatchELF = true;
    #   cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [ "-DCMAKE_BUILD_TYPE=Debug" ];
    # });
    # ghostty = prev.ghostty.overrideAttrs (oldAttrs: {
    #   patches = (oldAttrs.patches or [ ]) ++ [
    #     ./ghostty.patch
    #   ];
    # });
    electrum-custom = prev.electrum.overridePythonAttrs (oldAttrs: {
      version = "4.6.2";
      src = prev.fetchurl {
        url = "https://download.electrum.org/4.6.2/Electrum-4.6.2.tar.gz";
        hash = "sha256-ZrwzAeeMNrs6KzLGDg5oBF7E+GGLYCVczO6R18TKRuE=";
      };
      dependencies = with prev.python3.pkgs; [
        aiohttp
        aiohttp-socks
        aiorpcx
        attrs
        bitstring
        cryptography
        dnspython
        jsonrpclib-pelix
        matplotlib
        pbkdf2
        protobuf
        pysocks
        qrcode
        requests
        certifi
        jsonpatch
        electrum-aionostr
        electrum-ecc
        cbor2
        pyserial
        pyqt6
        qdarkstyle
      ];
    });
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  alternative-pkgs = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
