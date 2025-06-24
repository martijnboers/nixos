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

      cheese # webcam
      file-roller # archive manager

      # Office suite
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
      obsidian

      # programming
      pgrok
      sublime-merge
      awscli2
      httpie-desktop
      devenv
      beekeeper-studio # db

      # forensics
      volatility3
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
      cinny-desktop # matrix client
    ];

    programs.gpg = {
      enable = true;
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      scdaemonSettings = {
        disable-ccid = true;
      };
    };

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
