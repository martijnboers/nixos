{
  config,
  pkgs,
  ...
}:
let
  helpers = config.lib.nixvim;
  jsonPath = pkgs.writeText "global.json" (
    builtins.toJSON {
      date = {
        prefix = [
          "d"
          "date"
        ];
        desc = "Current date";
        body = "$CURRENT_DATE-$CURRENT_MONTH-$CURRENT_YEAR";
      };
      note = {
        prefix = "note";
        desc = "Note frontmatter template";
        body = ''
          ---
          title: ''${1}
          date: $CURRENT_DATE-$CURRENT_MONTH-$CURRENT_YEAR
          tags: ''${2}
          ---

          ''${3}
        '';
      };
      module = {
        prefix = "module";
        desc = "New nix module";
        body = ''
          {
            lib,
            config,
            ...
          }:
          with lib;
          let
            cfg = config.''${1|maatwerk,hosts|}.''${2};
          in
          {
            options.''${1}.''${2} = {
              enable = mkEnableOption "''${3}";
            };
            config = mkIf cfg.enable {
              ''${4}
            };
          }
        '';
      };
    }
  );
in
{
  programs.nixvim.plugins.mini.modules.snippets = {
    snippets = helpers.mkRaw ''
      {
        require("mini.snippets").gen_loader.from_file("${jsonPath}"),
        require("mini.snippets").gen_loader.from_lang(),
      }
    '';
  };
}
