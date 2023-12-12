{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";

  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@plebian.nl";
    signing = {
      key = "FDC7B670BF26B101";
      signByDefault = true;
    };
    extraConfig = {
      core.editor = "vim";
      pull.rebase = "true";
    };
  };

  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "sudo nixos-rebuild switch --flake /home/martijn/Nix#glassdoor";
      dud = "docker-compose up -d";
      fixup = "ga . && gc --amend --no-edit";
    };
    dotDir = ".config/zsh";
    initExtra = ''
      # Powerlevel10k Zsh theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck" "direnv" "fzf" "z"];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "mononoki Nerd Font Mono";
      font_size = "12.0";
      # Window
      background_opacity = "0.8";
      scrollback_lines = 10000;
      window_padding_width = 6;

      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Display
      sync_to_monitor = true;
    };
    theme = "Doom One";
  };

  # to get gpg to work
  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

  # KDE
  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorscheme = "BreezeDark";
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # work
    jetbrains.pycharm-community
    thefuck
    firefox
    vim
    sublime-merge
    joplin-desktop
    kitty

    # personal
    steam
    clementine

    # shell
    zsh-powerlevel10k
    meslo-lgs-nf

    # messaging
    signal-desktop
    telegram-desktop

    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq

    # networking tools
    dnsutils # `dig` + `nslookup`

    # terminal
    zoxide
    fzf # A command-line fuzzy finder
    direnv # used for .envrc files

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    git

    # for gpg
    gnupg
    pinentry

    htop
    btop # fancy htop
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
