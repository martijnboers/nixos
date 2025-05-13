{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.desktop;
in
{
  options.maatwerk.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    maatwerk.browser.enable = true;
    maatwerk.kitty.enable = true;
    maatwerk.stylix.enable = true;

    home.packages = with pkgs; [
      wl-clipboard # wayland clipboard manager
      kooha # record screen wayland
      wev # wayland xev

      yubioath-flutter # yubikey
      veracrypt
      seafile-client
      cheese # webcam
      file-roller # archive manager
      nerdfonts # icon font

      # Office suite
      stable.libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
      obsidian

      # programming
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      httpie-desktop
      wireshark

      # personal
      qflipper
      vlc
      ollama # for the client
      electrum # btc wallet

      # music
      clementine
      spotify

      # messaging
      signal-desktop
      telegram-desktop
      nheko # matrix client
    ];

    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vaultwarden.thuis";
        email = "martijn@plebian.nl";
        lock_timeout = 2 * 60 * 60;
        pinentry = pkgs.pinentry-gnome3;
      };
    };

  };
}
