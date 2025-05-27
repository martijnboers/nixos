{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
in
{
  config = mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          name = "openingh.nvim";
          src = pkgs.fetchFromGitHub {
            owner = "Almo7aya";
            repo = "openingh.nvim";
            rev = "7cc8c897cb6b34d8ed28e99d95baccef609ed251";
            sha256 = "sha256-/FlNLWOSIrOYiWzAcgOdu9//QTorCDV1KWb+h6eqLwk=";
          };
        })
      ];

      plugins = {
        gitsigns = {
          enable = true;
          autoLoad = true;
        }; # gutter signs, blame, hunk previews
      };

      keymaps = [
        # git stuff
        {
          action = "<cmd>OpenInGHFile<cr>";
          key = "<Leader>go";
          options.silent = true;
        }
        {
          action = ":OpenInGHFileLines<cr>"; # has to be : for range to work
          key = "<Leader>go";
          mode = [ "v" ];
          options.silent = true;
        }
        {
          action = "<cmd>Gitsigns blame<cr>";
          key = "<Leader>gb";
          options.desc = "Git blame";
        }
        {
          action = "<cmd>Gitsigns preview_hunk_inline<cr>";
          key = "<Leader>gp";
          options.desc = "Git preview hunk";
        }
        {
          action = "<cmd>Gitsigns reset_hunk<cr>";
          key = "<Leader>gu";
          options.desc = "Git undo changes";
        }
        {
          action = "<cmd>Telescope git_commits<cr>";
          key = "<Leader>gc";
        }
        {
          action = "<cmd>Telescope git_bcommits<cr>";
          key = "<Leader>gh";
          options.desc = "Git history of file";
        }
        {
          action = "<cmd>Telescope git_bcommits_range<cr>";
          key = "<Leader>gh";
          mode = [ "v" ];
          options.desc = "Git history of selection";
        }

      ];
    };
  };
}
