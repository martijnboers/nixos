{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    nerdfonts = final.stable.nerdfonts.override {
      fonts = ["RobotoMono" "JetBrainsMono"];
    };
    # Can't make into package because need unstable buildGo123Module
    headscale-bleeding = final.buildGo123Module rec {
      pname = "headscale";
      version = "0.23.0";

      src = prev.fetchFromGitHub {
        owner = "juanfont";
        repo = "headscale";
        rev = "v${version}";
        hash = "sha256-5tlnVNpn+hJayxHjTpbOO3kRInOYOFz0pe9pwjXZlBE=";
      };
      vendorHash = "sha256-+8dOxPG/Q+wuHgRwwWqdphHOuop0W9dVyClyQuh7aRc=";
      ldflags = ["-s" "-w" "-X github.com/juanfont/headscale/cmd/headscale/cli.Version=v${version}"];
      nativeBuildInputs = [prev.installShellFiles];
      checkFlags = ["-short"];

      postInstall = ''
        installShellCompletion --cmd headscale \
          --bash <($out/bin/headscale completion bash) \
          --fish <($out/bin/headscale completion fish) \
          --zsh <($out/bin/headscale completion zsh)
      '';
    };
    # https://www.jetbrains.com/webstorm/nextversion/
    webstorm-eap = prev.jetbrains.webstorm.overrideAttrs {
      version = "241.11761.28";
      # Patches don't work with new version
      postPatch = ''
        rm -rf jbr
        ln -s ${final.jdk.home} jbr
      '';
      src = builtins.fetchurl {
        url = "https://download-cdn.asgjetbrains.com/webstorm/WebStorm-242.14146.21.tar.gz";
        sha256 = "1p53p1mw0x4g409l514pji68van4w7jg1lx7lycy5ykqj0dbgp41";
      };
    };
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
