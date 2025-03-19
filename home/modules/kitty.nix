{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.maatwerk.kitty;
in {
  options.maatwerk.kitty = {
    enable = mkEnableOption "Terminal emulator";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [kitty];
    programs.kitty = {
      enable = true;
      shellIntegration = {
        enableZshIntegration = true;
        mode = "no-rc"; # https://sw.kovidgoyal.net/kitty/shell-integration/#configuration
      };
      settings = {
        scrollback_lines = 10000;
        window_padding_width = 6;
        hide_window_decorations = "no";
        tab_title_max_length = 60;
        tab_title_template = "{title}";
        strip_trailing_spaces = "always";

        # Don't do updates
        update_check_interval = 0;

        # Tabs
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        # Display
        sync_to_monitor = true;
        enable_audio_bell = false;
      };
      keybindings = {
        "ctrl+pgdn" = "next_tab";
        "ctrl+pgup" = "previous_tab";
        "ctrl+shift+pgdn" = "move_tab_forward";
        "ctrl+shift+pgup" = "move_tab_backward";
        "ctrl+shift+t" = "new_tab";
        "ctrl+w" = "close_tab";
        "alt+j" = "previous_window";
        "alt+k" = "next_window";
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
      };
      themeFile = "GruvboxMaterialDarkMedium";
    };
  };
}
