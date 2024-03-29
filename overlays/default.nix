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
    headscale = final.unstable.buildGo122Module rec {
      pname = "headscale";
      version = "0.23.0-alpha4";

      src = prev.fetchFromGitHub {
        owner = "juanfont";
        repo = "headscale";
        rev = "v${version}";
        hash = "sha256-BMrbYvxNAUs5vK7zCevSKDnB2npWZQpAtxoePXi5r40=";
      };

      vendorHash = "sha256-Yb5WaN0abPLZ4mPnuJGZoj6EMfoZjaZZ0f344KWva3o=";
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
