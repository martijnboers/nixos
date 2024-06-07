{
  inputs,
  outputs,
  system,
  pkgs,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "24.05";

  imports = [
    ./modules/neovim.nix
    ./modules/zsh.nix
    ./modules/atuin.nix

    # Packaged home manager modules
    inputs.nixvim.homeManagerModules.nixvim

    # quickly lookup and run programs
    inputs.nix-index-database.hmModules.nix-index

    # secrets manager
    inputs.agenix.homeManagerModules.default

    # rice
    inputs.stylix.homeManagerModules.stylix

    # Desktop only
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/kde.nix
    inputs.plasma-manager.homeManagerModules.plasma-manager

    # profiles based on type of computer usage
    ./profiles/personal.nix
    ./profiles/work.nix
  ];

  # Global user level packages
  home.packages = with pkgs; [
    # shell
    zsh-powerlevel10k
    zoxide
    fzf # A command-line fuzzy finder
    fd # easier find
    direnv # used for .envrc files
    ranger
    neofetch
    thefuck
    trash-cli
    lsd # fancy ls

    # fonts
    meslo-lgs-nf
    nerdfonts

    # tools
    distrobox # run any linux distro
    mods # ai for cli
    glow # cli markdown viewer
  ];

  # User level secrets
  age = {
    identityPaths = [
      "/home/martijn/.ssh/id_ed25519"
    ];
    secrets = {
      openai.file = ../secrets/openai.age;
    };
  };

  stylix = {
    image = assets/wallpaper2.jpg;
    polarity = "dark";
    cursor = {
      package = pkgs.phinger-cursors;
      name = "pakkarobaan";
      size = 28;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
    fonts = {
      serif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "Jetbrains Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
      # For Obsidian
      permittedInsecurePackages = [
        "electron-25.9.0"
      ];
    };
  };

  # Let nix-index handle command-not-found
  programs.nix-index.enable = true;
  # Run programs with , cowsay
  programs.nix-index-database.comma.enable = true;

  # Additional direnv flake support
  programs.direnv.nix-direnv.enable = true;

  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@plebian.nl";
    signing = {
      key = "FDC7B670BF26B101";
      signByDefault = true;
    };
    extraConfig = {
      pull.rebase = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      safe.directory = "/home/martijn/Nix/.git";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
