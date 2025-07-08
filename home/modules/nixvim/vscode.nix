{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;
  mkGotoBuffer = index: {
    action = "<cmd>BufferGoto ${toString index}<cr>";
    key = "<C-${toString (index + 5)}>"; # use right side of keyboard
    options.desc = "Go to buffer ${toString index}";
  };
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vimPlugins.sqlite-lua # smart-open
    ];

    programs.nixvim = {
      extraPlugins = with pkgs.vimPlugins; [
        smart-open-nvim
      ];

      plugins = {
        barbar = {
          enable = true;
          settings = {
            clickable = true;
            animations = false;
            auto_hide = 1;
            icons = {
              button = false; # don't show close button
              preset = "default";
              pinned = {
                button = "";
                filename = true;
              };
              diagnostics = {
                # error
                "1" = {
                  enabled = true;
                  icon = "󰈸";
                };
              };
            };
          };
        }; # tabs, as understood by any other editor.

        # File explorer
        mini = {
          modules.files = {
            mappings = {
              close = "q";
              go_in = "l";
              go_out = "h";
              mark_goto = "'";
              mark_set = "m";
              reveal_cwd = "@";
              show_help = "g?";
              synchronize = "=";
              trim_left = "<";
              trim_right = ">";
            };
          };
        };

        telescope = {
          enable = true;
          enabledExtensions = [ "smart_open" ];
          keymaps = {
            "<Leader>f" = "live_grep";
            "<Leader>/" = "current_buffer_fuzzy_find";
            "<Leader>s" = "lsp_document_symbols";
            "<Leader>h" = "help_tags";
            "<Leader>x" = "diagnostics";
            "<Leader>b" = "buffers";
          };
          settings = {
            defaults.file_ignore_patterns = [
              "^.git/"
              "^.mypy_cache/"
              "^__pycache__/"
              "^.direnv/"
              "^output/"
              "^data/"
              "%.ipynb"
            ];
            pickers = {
              smart_open = {
                theme = "vertical";
              };
              lsp_document_symbols = {
                theme = "ivy";
              };
              help_tags = {
                theme = "ivy";
              };
              current_buffer_fuzzy_find = {
                theme = "ivy";
              };
              buffers = {
                theme = "ivy";
              };
              live_grep = {
                layout_strategy = "vertical";
              };
            };
          };
        }; # Find popups for files + more
      };

      keymaps = [
        # file explorer
        {
          action = helpers.mkRaw ''
            function(...)
              if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end
            end
          '';
          key = "<Leader>e";
          mode = [
            "n"
            "v"
          ];
          options = {
            desc = "Toggle MiniFiles";
            silent = true;
          };
        }

        # Telescope
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

        # Buffers
        {
          action = "<cmd>BufferPrevious<cr>";
          key = "<Left>";
          options.desc = "Go to prev buffer";
        }
        {
          action = "<cmd>BufferNext<cr>";
          key = "<Right>";
          options.desc = "Go to next buffer";
        }
        {
          action = "<cmd>BufferMovePrevious<cr>";
          key = "<C-Left>";
          options.desc = "Move buffer left";
        }
        {
          action = "<cmd>BufferMoveNext<cr>";
          key = "<C-Right>";
          options.desc = "Move buffer to the right";
        }
        (mkGotoBuffer 1)
        (mkGotoBuffer 2)
        (mkGotoBuffer 3)
        (mkGotoBuffer 4)
        (mkGotoBuffer 5)
        {
          action = "<cmd>BufferPin<cr>";
          key = "<Leader>a";
          options.desc = "Move buffer to the right";
        }
        {
          action = helpers.mkRaw ''
            function ()
              vim.api.nvim_buf_delete(0, {})
            end
          '';
          key = "x";
          options.desc = "close buffer";
        }
        {
          action = "<cmd>BufferCloseAllButCurrentOrPinned<cr>";
          key = "X";
          options.desc = "Close all but pinned or current";
        }
        {
          action = "<C-w>w";
          key = "<Tab>";
          options.desc = "Switch window";
        }
        {
          action = "<C-w>W";
          key = "<S-Tab>";
          options.desc = "Prev window";
        }
      ];
    };
  };
}
