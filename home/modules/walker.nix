{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.hyprland;

  colors = config.lib.stylix.colors.withHashtag;
  fonts = config.stylix.fonts;
  opacity = config.stylix.opacity;
in
{
  config = mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
      config = {
        theme = "stylix";
        providers = {
          default = [
            "desktopapplications"
            "websearch"
            "calc"
          ];
          prefixes = [
            {
              provider = "files";
              prefix = "/";
            }
            {
              provider = "clipboard";
              prefix = "\\";
            }
            {
              provider = "symbols";
              prefix = ":";
            }
          ];
        };
        keybinds.quick_activate = [
          "ctrl j"
          "ctrl k"
          "ctrl l"
        ];
      };

      themes.stylix = {
        style = # css
          ''
            @define-color window_bg_color ${colors.base00};
            @define-color accent_bg_color ${colors.base0D};
            @define-color theme_fg_color ${colors.base05};
            @define-color error_bg_color ${colors.base08};
            @define-color error_fg_color ${colors.base00};

            * {
              all: unset;
              font-family: "${fonts.sansSerif.name}";
              font-size: ${toString fonts.sizes.popups}pt;
            }

            popover {
              background: ${colors.base01};
              border: 1px solid ${colors.base03};
              border-radius: 18px;
              padding: 10px;
            }

            .normal-icons { -gtk-icon-size: 16px; }
            .large-icons { -gtk-icon-size: 32px; }
            .search-container { border-radius: 10px; }
            .input placeholder { opacity: 0.5; }
            .list { color: @theme_fg_color; }

            scrollbar { opacity: 0; }

            .box-wrapper {
              box-shadow: 0 19px 38px rgba(0, 0, 0, 0.3), 0 15px 12px rgba(0, 0, 0, 0.22);
              background: alpha(@window_bg_color, ${toString opacity.popups});
              padding: 20px;
              border-radius: 20px;
              border: 1px solid @accent_bg_color;
            }

            .preview-box, .elephant-hint, .placeholder {
              color: @theme_fg_color;
            }

            .input selection {
              background: ${colors.base02};
            }

            .input {
              caret-color: @theme_fg_color;
              background: ${colors.base01};
              padding: 10px;
              color: @theme_fg_color;
              border-radius: 8px;
            }

            .item-box {
              border-radius: 10px;
              padding: 10px;
            }

            .item-quick-activation {
              background: alpha(@accent_bg_color, 0.25);
              border-radius: 5px;
              padding: 10px;
              color: ${colors.base0A}; 
            }

            child:selected .item-box {
              background: alpha(@accent_bg_color, 0.4);
            }

            .item-subtext {
              font-size: ${toString (fonts.sizes.popups - 2)}pt;
              opacity: 0.6;
            }

            .preview {
              border: 1px solid alpha(@accent_bg_color, 0.25);
              border-radius: 10px;
              color: @theme_fg_color;
            }

            .keybind-label, 
            .keybind-bind {
              font-size: ${toString (fonts.sizes.popups - 4)}pt;
            }

            .keybind-label {
              padding: 1px 4px;
              border-radius: 4px;
              background: alpha(@theme_fg_color, 0.05);
              border: 1px solid alpha(@theme_fg_color, 0.2);
            }

            .keybind-bind {
              font-size: ${toString (fonts.sizes.popups - 5)}pt;
              opacity: 0.5;
              margin-top: 2px;
            }

            .keybinds {
              padding-top: 10px;
              margin-top: 5px;
              border-top: 1px solid alpha(@theme_fg_color, 0.1);
            }

            .error {
              padding: 10px;
              background: @error_bg_color;
              color: @error_fg_color;
            }
          '';
      };
    };

  };
}
