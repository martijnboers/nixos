{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  home-env,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "23.11";

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config.allowUnfree = true;
  };

  imports =
    [
      ./modules/ranger.nix
      ./modules/neovim.nix
      ./modules/zsh.nix
      ./modules/atuin.nix

      # Packaged home manager modules
      inputs.nixvim.homeManagerModules.nixvim

      # quickly lookup and run programs
      inputs.nix-index-database.hmModules.nix-index
    ]
    ++ lib.optionals home-env.desktop [
      ./modules/kitty.nix
      ./modules/kde.nix
      inputs.plasma-manager.homeManagerModules.plasma-manager
    ];

  # All user level packages
  home.packages = with pkgs;
    [
      # shell
      zsh-powerlevel10k
      zoxide
      fzf # A command-line fuzzy finder
      direnv # used for .envrc files
      ranger
      neofetch
      thefuck
      trash-cli

      # fonts
      meslo-lgs-nf
      roboto
      jetbrains-mono

      # tools
      distrobox # run any linux distro
    ]
    ++ lib.optionals home-env.work [
      jetbrains.pycharm-community
      sublime-merge
      awscli2
      slack
      mongodb-compass
      nodejs_18 # global for work, move to project
      python311Full # move to projects
      httpie-desktop
    ]
    ++ lib.optionals home-env.desktop [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.neochat
      libsForQt5.kompare
      wl-clipboard # wayland clipboard manager
      joplin-desktop

      # theming
      nordic
      materia-kde-theme
      gimp
    ]
    ++ lib.optionals home-env.personal [
      steam
      wine
      clementine
      spotify
      qmk
      qflipper

      # messaging
      signal-desktop
      telegram-desktop
    ];

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
    };
  };

  programs.ranger = {
    enable = true;
    extraConfig = ''
      map e shell vim %c
      set vcs_aware true
      set draw_borders separators
      set nested_ranger_warning error
      set preview_images true
      set preview_images_method kitty
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
