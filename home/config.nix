{
  inputs,
  pkgs,
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

  imports = [
    # Custom modules
    ./modules/ranger.nix

    # Configs that are large
    ./neovim.nix
    ./kde.nix
    ./zsh.nix
    ./kitty.nix

    # Packaged home manager modules
    inputs.plasma-manager.homeManagerModules.plasma-manager
    inputs.nixvim.homeManagerModules.nixvim
  ];

  # All user level packages
  home.packages = with pkgs; [
    # work
    jetbrains.pycharm-community
    thefuck
    firefox
    ungoogled-chromium
    sublime-merge
    joplin-desktop
    awscli2

    # personal
    steam
    wine
    clementine
    spotify
    qmk
    qflipper

    # theming
    nordic
    materia-kde-theme
    roboto
    jetbrains-mono
    gimp

    # shell
    zsh-powerlevel10k
    meslo-lgs-nf
    kitty
    zoxide
    fzf # A command-line fuzzy finder
    direnv # used for .envrc files
    ranger
    neofetch
    wl-clipboard # wayland clipboard manager

    # messaging
    signal-desktop
    telegram-desktop

    # KDE stuff
    libsForQt5.kdeconnect-kde
    libsForQt5.neochat
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
