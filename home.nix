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
  };

  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "cd ~/Nix && sudo nixos-rebuild switch --flake .#glassdoor";
      dud = "docker-compose up -d";
      fixup = "ga . && gc --amend --no-edit";
    };
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck"];
#      theme = "power10k";
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
    fzf # A command-line fuzzy finder

    # networking tools
    dnsutils # `dig` + `nslookup`

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

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

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
