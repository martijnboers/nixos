{...}: {
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Jetbrains Mono";
      font_size = "12.0";
      scrollback_lines = 10000;
      window_padding_width = 6;

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
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+w" = "close_tab";
      "alt+j" = "previous_window";
      "alt+k" = "next_window";
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
    };
    theme = "Gruvbox Material Dark Medium";
  };
}
