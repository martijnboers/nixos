{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.maatwerk.ghostty;
in
{
  options.maatwerk.ghostty = {
    enable = mkEnableOption "Terminal emulator";
  };
  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      clearDefaultKeybinds = true;
      systemd.enable = true;

      settings = {
        gtk-tabs-location = "bottom";
        gtk-toolbar-style = "flat";
        gtk-titlebar-hide-when-maximized = true;
        scrollback-limit = 500 * 1024 * 1024; # 500mb
        freetype-load-flags = "no-force-autohint";
	shell-integration-features = "ssh-terminfo";
        keybind = [
          "ctrl+shift+page_down=move_tab:1"
          "ctrl+shift+page_up=move_tab:-1"
	  "ctrl+shift+c=copy_to_clipboard"
	  "ctrl+shift+v=paste_from_clipboard"
	  "ctrl+shift+r=prompt_surface_title"
	  "ctrl+shift+f=write_scrollback_file:paste"
          "ctrl+shift+a=select_all"
          "ctrl+page_down=next_tab"
          "ctrl+page_up=previous_tab"
          "ctrl+shift+t=new_tab"
          "ctrl+w=close_tab:this"
          "ctrl+9=decrease_font_size:1"
          "ctrl+0=increase_font_size:1"
        ];
      };
    };
  };
}
