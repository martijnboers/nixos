{
  lib,
  pkgs,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@plebian.nl";
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

  # KDE
#  programs.plasma = {
#    enable = true;
#
#    workspace = {
#      clickItemTo = "select";
#      tooltipDelay = 5;
#      theme = "breeze-dark";
#      colorscheme = "BreezeDark";
#    };
#  };


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # work
    jetbrains.pycharm-community
    thefuck
    firefox
    vim
    sublime-merge
    joplin-desktop

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
