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
          package = pkgs.roboto-serif;
          name = "Roboto Serif";
        };
        sansSerif = {
          package = pkgs.roboto-flex;
          name = "Roboto Flex";
        };
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "Jetbrains Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes.popups = 14; # for fuzzel
      };
      targets.librewolf.enable = false;
      targets.nixvim.enable = false;
      targets.hyprlock.enable = false;
      targets.swaync.enable = false;
    };
  };
}
