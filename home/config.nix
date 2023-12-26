{
  inputs,
  pkgs,
  lib,
  special-options,
  ...
}: {
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "23.11";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
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
      meslo-lgs-nf
      zoxide
      fzf # A command-line fuzzy finder
      direnv # used for .envrc files
      ranger
      neofetch
      thefuck
    ]
    ++ lib.optionals special-options.isWork [
      jetbrains.pycharm-community
      sublime-merge
      awscli2
    ]
    ++ lib.optionals special-options.isDesktop [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.neochat
      wl-clipboard # wayland clipboard manager
      joplin-desktop

      # theming
      nordic
      materia-kde-theme
      roboto
      jetbrains-mono
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
}
