{config, pkgs, ...} : {
stylix = {
    enable = true;
    image = ../assets/img/wallpaper2.jpg;
    polarity = "dark";
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 26;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
    fonts = {
      serif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "Jetbrains Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    targets.firefox = {
      enable = true;
      profileNames = ["default"];
    };
    override.base0D = "#ffcb6b"; # https://github.com/danth/stylix/issues/430
    targets.nixvim.enable = false;
  };
}
