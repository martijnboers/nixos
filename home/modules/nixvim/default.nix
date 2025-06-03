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
in
{

  options.maatwerk.nixvim = {
    enable = mkEnableOption "Full nixvim install";
  };

  imports = [
    ./tabs.nix
    ./lsp.nix
    ./git.nix
    ./dap.nix
  ];

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      extraPlugins = with pkgs.vimPlugins; [
        eyeliner-nvim # highlight t&f searches
      ];

      extraConfigLua = ''
        require("eyeliner").setup {
          highlight_on_key = true,
          dim = true
        }
      '';

      globals = {
        mapleader = " "; # map leader to spacebar
      };

      keymaps = [
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
          action = "<cmd>Precognition toggle<cr>";
          key = "<Leader>j";
        }
        {
          action = "<C-i>"; # needed because mapping tab breaks CTRL-i in kitty
          key = "<C-i>";
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

      plugins = {
        web-devicons.enable = true; # needed for other plugins
        noice.enable = true; # cmd popup input modal

        # training wheels
        which-key.enable = true; # popup with possible key combinations
        precognition = {
          enable = true;
          settings = {
            showBlankVirtLine = false; # don't when no virtlines
            startVisible = false; # only show on toggle
          };
        }; # jump reference helper

        auto-session = {
          enable = true;
          settings.pre_save_cmds = helpers.mkRaw ''
            {
                function()
                  vim.api.nvim_exec_autocmds('User', {pattern = 'SessionSavePre'})
                end,
            }
          '';
        }; # auto-restore sessions on startup

        mini = {
          enable = true;
          modules = {
            move = {
              mappings = {
                up = "<C-S-Up>";
                down = "<C-S-Down>";
                line_up = "<C-S-Up>";
                line_down = "<C-S-Down>";
              };
            }; # move line(s) up and down
            move = {
              surround = {
                add = "sa";
                delete = "sd";
              };
            }; # surround words with something
          };
        };

        render-markdown = {
          enable = true;
          settings.render_modes = true;
        }; # better markdown support

        alpha = {
          enable = true;
          layout = [
            {
              type = "padding";
              val = 2;
            }
            {
              opts = {
                hl = "Type";
                position = "center";
              };
              type = "text";
              val = [
                "                                   "
                "                                   "
                "                                   "
                "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          "
                "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       "
                "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     "
                "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    "
                "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   "
                "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  "
                "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   "
                " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  "
                " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ "
                "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     "
                "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     "
                "                                   "
              ];
            }
            {
              type = "padding";
              val = 2;
            }
            {
              opts = {
                hl = "Keyword";
                position = "center";
              };
              type = "text";
              val = "\"Krentenbol\" -- Regenboog 6";
            }
          ];
        }; # rice
      };

      opts = {
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        shiftwidth = 2; # Tab width should be 2
        swapfile = false; # No more .swp files
        autoread = true; # autoreload changed files
        undofile = true; # save undo history
        ignorecase = true; # case insensitive search
        smartcase = true; # when adding cases to search, becomes case sensitive
        scrolloff = 8; # start scrolling when 8 lines left
        sidescrolloff = 8; # same for side scrolling
        laststatus = 0; # hide bottom bar, noice does this
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,globals";
      };

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
          colors.theme.all.ui.bg_gutter = "none";
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
