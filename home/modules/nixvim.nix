{
  lib,
  config,
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

  options.maatwerk.nixvim = {
    enable = mkEnableOption "Full nixvim install";
  };

  imports = [
    ./lsp.nix
    ./dap.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
      fd
      git
    ];

    programs.nixvim = {
      enable = true;

      globals = {
        mapleader = " "; # map leader to spacebar
      };

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

      opts = {
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        shiftwidth = 2; # Tab width should be 2
        swapfile = false; # No more .swp files
        autoread = true; # autoreload changed files
        ignorecase = true; # case insensitive search
        smartcase = true; # when adding cases to search, becomes case sensitive
        scrolloff = 8; # start scrolling when 8 lines left
        sidescrolloff = 8; # same for side scrolling
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,globals";
        numberwidth = 6; # indent current line number
        termguicolors = true; # more colors, makes linenumber color work
        cursorline = true; # for line number color, rest is ignored
      };

      plugins = {
        noice.enable = true; # cmd popup input modal
        auto-session.enable = true; # auto-restore sessions on startup
        gitsigns.enable = true; # gutter signs, blame, hunk previews
	mini-extra.enable = true; # more picker sources 

        telescope = {
          enable = true;
          keymaps = {
            "<Leader>f" = "live_grep";
            "<Leader>/" = "current_buffer_fuzzy_find";
            "<Leader>s" = "lsp_document_symbols";
            "<Leader>h" = "help_tags";
            "<Leader>x" = "diagnostics";
            "<Leader>b" = "buffers";
          };
        }; # Find popups for files + more

        barbar = {
          enable = true; # tabs, as understood by any other editor.
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
        };

        which-key = {
          enable = true; # shortcut hints
          settings = {
            delay = 900;
          };
        };

        mini-statusline = {
          enable = true;
          settings = {
            use_icons = false;
            content = {
              active = helpers.mkRaw ''
                function()
                  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 200 })
                  local diff          = MiniStatusline.section_diff({ icon = "  ", trunc_width = 70 })
                  local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 70 })
                  local path          = MiniStatusline.section_filename({ trunc_width = 10 })

                  return MiniStatusline.combine_groups({
                    { hl = mode_hl,               strings = { mode } },
                    '%<',
                    { hl = 'MiniStatuslineLocation', strings = { path } },
                    '%=',
                    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                    { hl = 'MiniStatuslineDiff',  strings = {  diff } },
                  })
                end
              '';
            };
          };
        };


        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            files.enable = true; # file explorer
            pick.enable = true; # file picker
            icons.enable = true; # icons support for extensions
            move = {
              mappings = {
                up = "<C-S-Up>";
                down = "<C-S-Down>";
                line_up = "<C-S-Up>";
                line_down = "<C-S-Down>";
              };
            };
            surround = {
              add = "sa";
              delete = "sd";
            }; # surround words with something
          };
        };

        render-markdown = {
          enable = true; # better markdown support
          settings.render_modes = true;
        };
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
          action = "<C-i>"; # needed because mapping tab breaks CTRL-i in kitty
          key = "<C-i>";
        }
        {
          action = "\"+y";
          key = "<Leader>c";
          mode = [
            "v"
          ];
          options = {
            desc = "Add to sytem clipboard";
            silent = true;
          };
        }
        {
          action = "<cmd>%y+<cr>";
          key = "<Leader>c";
          mode = [
            "n"
          ];
          options = {
            desc = "Add whole file to sytem clipboard";
            silent = true;
          };
        }
      ];

      diagnostic.settings = {
        virtual_text = false;
        virtual_lines = {
          enable = true;
          current_line = true;
        };
      };

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          dimInactive = true;
          overrides = # lua
            ''
              function(colors)
                local theme = colors.theme
                return {
                  LineNr = { bg = "none" },
                  SignColumn = { bg = "none" },
                  GitSignsAdd = { bg = "none" },
                  GitSignsChange = { bg = "none" },
                  GitSignsDelete = { bg = "none" },
                  CursorLine = { bg = "none" },
                  CursorLineNr = {
                    fg = colors.palette.oldWhite,
                    bg = "none", 
                  },
                }
              end
            '';
          background = {
            light = "wave";
            dark = "dragon";
          };
        };
      };

      clipboard = {
        providers.wl-copy.enable = true;
      };
    };
  };
}
