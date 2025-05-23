{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  mkHarBind = index: key: {
    inherit key;
    action = helpers.mkRaw ''function() require("harpoon"):list():select(${toString index}) end'';
  };
  helpers = config.lib.nixvim;
in
{
  config = mkIf cfg.enable {
    programs.nixvim = {
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

        # harpoon
        {
          action = helpers.mkRaw ''
            function() 
              require("harpoon"):list():add() 
              require("barbecue.ui").update()
            end
          '';
          key = "<Leader>a";
          options.desc = "Add to harpoon";
        }
        {
          action = helpers.mkRaw ''function() local harpoon = require('harpoon') harpoon.ui:toggle_quick_menu(harpoon:list()) end '';
          key = "<C-g>";
          options.desc = "Harpoon menu";
        }
        {
          action = helpers.mkRaw ''function() require('harpoon'):list():next() end '';
          key = "<C-S-Right>";
          options.desc = "Harpoon next";
        }
        {
          action = helpers.mkRaw ''function() require('harpoon'):list():prev() end '';
          key = "<C-S-Left>";
          options.desc = "Harpoon prev";
        }
        (mkHarBind 1 "<C-j>")
        (mkHarBind 2 "<C-k>")
        (mkHarBind 3 "<C-l>")
        (mkHarBind 4 "<C-;>")

        # one off
        {
          action = "<cmd>Neotree reveal right toggle<cr>";
          key = "<Leader>e";
          options.desc = "Toggle file explorer";
        }
        {
          action = helpers.mkRaw ''function() require("telescope.builtin").grep_string() end '';
          key = "<Leader>f";
          mode = [ "v" ];
          options.desc = "Find text in selection";
        }
        {
          action = helpers.mkRaw ''
            function() require('telescope').extensions.smart_open.smart_open {
              cwd_only = true,
              filename_first = false,
            } end '';
          key = "<Leader>o";
          options.desc = "Smart open files";
        }
        {
          action = helpers.mkRaw ''
            function() require("conform").format({ 
              lsp_fallback = true,
              async = false,
              timeout_ms = 500, 
            }) end '';
          mode = [
            "v"
            "n"
          ];
          key = "<Leader>=";
          options.desc = "format selection or whole buffer";
        }

        # quality of life stuff
        {
          action = "<C-u>zz";
          key = "<C-u>";
        }
        {
          action = "<C-d>zz";
          key = "<C-d>";
        }
        {
          action = "<C-w>w";
          key = "<Tab>";
          options.desc = "switch buffer";
        }
        {
          action = "<C-i>"; # needed because mapping tab breaks CTRL-i in kitty
          key = "<C-i>";
        }
        {
          action = "<C-w>W";
          key = "<S-Tab>";
          options.desc = "prev buffer";
        }
        {
          action = "<cmd>bd<cr>";
          key = "x";
          options.desc = "close buffer";
        }
        {
          action = "\"+y";
          key = "<Leader>c";
          mode = [
            "n"
            "v"
          ];
          options = {
            desc = "Add to sytem clipboard";
            silent = true;
          };
        }
      ];
    };
  };
}
