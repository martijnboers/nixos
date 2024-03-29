# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    ollama = final.unstable.ollama;

    libsForQt5 =
      prev.libsForQt5
      // {
        # Use unstable plasma for wayland
        sddm = final.unstable.libsForQt5.sddm;
        plasma-desktop = final.unstable.libsForQt5.plasma-desktop;
      };
    headscale = prev.headscale.overrideAttrs (old: rec {
      version = "0.23.0-alpha5";
      src = prev.fetchFromGitHub {
        owner = "juanfont";
        repo = "headscale";
        rev = "v${version}";
        hash = "sha256-nqmTqe3F3Oh8rnJH0clwACD/0RpqmfOMXNubr3C8rEc=";
      };
      vendorHash = "sha256-IOkbbFtE6+tNKnglE/8ZuNxhPSnloqM2sLgTvagMmnc=";
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
