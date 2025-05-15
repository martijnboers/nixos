{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: {
    nerdfonts = final.stable.nerdfonts.override {
      fonts = [
        "RobotoMono"
        "JetBrainsMono"
      ];
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
