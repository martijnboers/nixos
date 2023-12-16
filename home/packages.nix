{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # work
    jetbrains.pycharm-community
    thefuck
    firefox
    vim
    neovim
    sublime-merge
    joplin-desktop
    kitty

    # personal
    steam
    lutris
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
    ranger

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    git
    wev # wayland xev
    gcc
    tldr

    # for gpg
    gnupg
    pinentry

    htop
    btop # fancy htop
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    lsof # list open files

    # system tools
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
