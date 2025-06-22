{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.stylix;
in
{
  options.maatwerk.stylix = {
    enable = mkEnableOption "Automatic styling";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-font-viewer
      inter-nerdfont
    ];

    # file:///home/martijn/.config/stylix/palette.html
    stylix = {
      enable = true;
      image = ../assets/img/wp_2.jpg;
      polarity = "dark";
      cursor = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors-light";
        size = 26;
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
      fonts = {
        serif = {
          package = pkgs.inter;
          name = "Inter Display, Light Italic";
        };
        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetbrainsMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes.popups = 14; # for fuzzel
      };
      targets = {
        librewolf.enable = false;
        nixvim.enable = false;
        hyprlock.enable = false;
        swaync.enable = false;
      };
    };
  };
}
