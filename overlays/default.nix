{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

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
      version = "0.23.0-alpha5";

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

      # https://www.jetbrains.com/webstorm/nextversion/
      webstorm-eap = final.unstable.jetbrains.webstorm.overrideAttrs {
        version = "241.11761.28";
        # Patches don't work with new version
        postPatch = ''
          rm -rf jbr
          ln -s ${final.jdk.home} jbr
        '';
        src = builtins.fetchurl {
          url = "https://download-cdn.jetbrains.com/webstorm/WebStorm-241.14494.25.tar.gz";
          sha256 = "04rpag23w55mxm98q8gggdc5n1ax2h4qy7ks7rc7825r3cail94q";
        };
      };
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
