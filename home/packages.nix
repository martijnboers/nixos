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
    ungoogled-chromium
    sublime-merge
    joplin-desktop
    awscli2

    # personal
    steam
    bottles
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
}
