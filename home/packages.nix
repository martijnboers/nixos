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
    sublime-merge
    joplin-desktop

    # personal
    steam
    lutris
    clementine
    spotify
    qmk

    # theming
    nordic
    materia-kde-theme
    roboto
    jetbrains-mono

    # shell
    zsh-powerlevel10k
    meslo-lgs-nf
    kitty
    zoxide
    fzf # A command-line fuzzy finder
    direnv # used for .envrc files
    ranger
    neofetch

    # messaging
    signal-desktop
    telegram-desktop

    # KDE stuff
    libsForQt5.kdeconnect-kde
    libsForQt5.neochat
  ];
}
