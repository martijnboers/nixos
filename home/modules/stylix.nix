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
    home.packages = with pkgs; [ gnome-font-viewer ];
    # file:///home/martijn/.config/stylix/palette.html
    stylix = {
      enable = true;
      image = pkgs.fetchurl {
        url = "https://share.boers.email/api/shares/wallpaper/files/c99a73c1-577e-4d8e-906f-166bbe5f2270";
        hash = "sha256-/hoTDZyWcnULIR944i262HOZEpoNMnSFc+40KnlU/3Y=";
      };
      polarity = "dark";
      icons = {
        enable = true;
        package = pkgs.tela-icon-theme;
        dark = "Tela";
      };
      cursor = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors-light";
        size = 26;
      };
      # https://tinted-theming.github.io/tinted-gallery/
      base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";
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
        sizes = {
          terminal = 13;
          popups = 14;
        };
      };
      targets = {
        librewolf = {
          enable = true;
          colorTheme.enable = true;
          profileNames = [ "default" ];
        };
        waybar.enable = false;
        nixvim.enable = false;
        hyprlock.enable = false;
      };
    };
  };
}
