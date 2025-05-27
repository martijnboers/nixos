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
        (pkgs.vimUtils.buildVimPlugin {
          name = "neo-tree-diagnostics.nvim";
          doCheck = false;
          src = pkgs.fetchFromGitHub {
            owner = "mrbjarksen";
            repo = "neo-tree-diagnostics.nvim";
            rev = "e00434c3cf8637bcaf70f65c2b9d82b0cc9bd7dc";
            sha256 = "sha256-HU7pFsICHK6bg03chgZ1oP6Wx2GQxk7ZJHGQnD0IMBA=";
          };
        })
      ];

      plugins = {
        barbar = {
          enable = true;
          settings = {
            clickable = false;
            animations = false;
            auto_hide = 1;
            icons = {
              button = false; # don't show close button
              preset = "powerline";
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

        telescope = {
          enable = true;
          enabledExtensions = [ "smart_open" ];
          keymaps = {
            "<Leader>f" = "live_grep";
            "<Leader>/" = "current_buffer_fuzzy_find";
            "<Leader>s" = "lsp_document_symbols";
            "<Leader>E" = "find_files";
            "<Leader>h" = "help_tags";
            "<Leader>x" = "diagnostics";
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
              current_buffer_fuzzy_find = {
                theme = "ivy";
              };
              live_grep = {
                layout_strategy = "vertical";
              };
            };
          };
        }; # Find popups for files + more

        neo-tree = {
          enable = true;
          hideRootNode = true;
          closeIfLastWindow = true;
          sources = [
            "filesystem"
            "document_symbols"
            "diagnostics"
            "git_status"
          ];
          eventHandlers = {
            file_opened = # lua
              ''
                function(file_path)
                  --auto close after opening file
                  require("neo-tree").close_all()
                end
              '';
          };
          sourceSelector = {
            winbar = false; # show icons
            contentLayout = "center";
            sources = [
              {
                displayName = " 󰱼 ";
                source = "filesystem";
              }
              {
                displayName = "  ";
                source = "document_symbols";
              }
              {
                displayName = "  ";
                source = "diagnostics";
              }
              {
                displayName = "  ";
                source = "git_status";
              }
            ];
          };
          window.width = 30;
          filesystem.window.mappings = {
            "<Left>" = "close_node";
            "<Right>" = "toggle_node";
          };
          buffers.followCurrentFile.enabled = true;
          filesystem.followCurrentFile.enabled = true;
          extraOptions = {
            diagnostics = {
              follow_current_file = {
                enabled = true;
                always_focus_file = true;
                expand_followed = true;
              };
            };
          };
        }; # right pane with files
      };

      keymaps = [
        {
          action = "<cmd>Neotree reveal right toggle<cr>";
          key = "<Leader>o";
          options.desc = "Toggle file explorer";
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
          key = "<Leader>e";
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
          action = "<cmd>bd<cr>";
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
