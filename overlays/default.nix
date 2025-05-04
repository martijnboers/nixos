{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    nerdfonts = final.stable.nerdfonts.override {
      fonts = [
        "RobotoMono"
        "JetBrainsMono"
      ];
    };

    mastodon = prev.mastodon.override {
      pname = "glitch-soc";
      srcOverride = final.pkgs.callPackage ./../pkgs/glitch-soc.nix { };
    };

    winapps-patched =
      let
        app = inputs.winapps.packages."x86_64-linux".winapps;
      in
      app.overrideAttrs {
        patches = app.patches ++ [ ./winapps.patch ];
      };

    wp4nix = builtins.fetchGit {
      url = "https://git.helsinki.tools/helsinki-systems/wp4nix";
      ref = "master";
    };
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  alternative-pkgs = final: _prev: {
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
