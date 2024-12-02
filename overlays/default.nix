{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    nerdfonts = final.stable.nerdfonts.override {
      fonts = ["RobotoMono" "JetBrainsMono"];
    };

    winapps-patched = let
      app = inputs.winapps.packages."x86_64-linux".winapps;
    in
      app.overrideAttrs {
        patches = app.patches ++ [./winapps.patch];
      };

    wp4nix = builtins.fetchGit {
      url = "https://git.helsinki.tools/helsinki-systems/wp4nix";
      ref = "master";
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
    fork = import inputs.nixpkgs-fork {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
