{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  special-options,
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
      # Custom modules
      ./modules/ranger.nix

      # Configs that are large
      ./neovim.nix
      ./zsh.nix

      # Packaged home manager modules
      inputs.nixvim.homeManagerModules.nixvim
    ]
    ++ lib.optionals special-options.isDesktop [
      ./kitty.nix
      ./kde.nix
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
      comma # wrapper for nix run, run program without installing
      nix-index # search files in upstream: nix-locate 'bin/hello'
    ]
    ++ lib.optionals special-options.isWork [
      jetbrains.pycharm-community
      sublime-merge
      awscli2
      slack
      mongodb-compass
      nodejs_18 # global for work, move to project
      python311Full # move to projects
      httpie-desktop
    ]
    ++ lib.optionals special-options.isDesktop [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.neochat
      libsForQt5.kate
      libsForQt5.kompare
      wl-clipboard # wayland clipboard manager
      joplin-desktop

      # theming
      nordic
      materia-kde-theme
      gimp
    ]
    ++ lib.optionals special-options.isPersonal [
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
