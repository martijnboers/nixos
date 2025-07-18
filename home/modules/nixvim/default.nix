{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
in
{

  options.maatwerk.nixvim = {
    enable = mkEnableOption "Full nixvim install";
  };

  imports = [
    ./vscode.nix
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
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,globals";
      };

      plugins = {
        web-devicons.enable = true; # needed for other plugins
        noice.enable = true; # cmd popup input modal
        auto-session.enable = true; # auto-restore sessions on startup
        which-key.enable = true; # popup with possible key combinations

        mini-statusline = {
          enable = true;
          settings = {
            use_icons = false;
            content = {
              active = {
                __raw = ''
                  function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 200 })
                    local diff          = MiniStatusline.section_diff({ icon = "  ", trunc_width = 70 })
                    local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 70 })
                    local search        = MiniStatusline.section_searchcount({ trunc_width = 30 })
                    local path        	= MiniStatusline.section_filename({ trunc_width = 10 })

                    return MiniStatusline.combine_groups({
                      { hl = mode_hl,               strings = { mode } },
                      '%<',
                      { hl = 'MiniStatuslineLocation', strings = { search, path } },
                      '%=',
                      { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                      { hl = 'MiniStatuslineDiff',  strings = {  diff } },
                    })
                  end
                '';
              };
            };
          };
        };

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
            surround = {
              add = "sa";
              delete = "sd";
            }; # surround words with something
          };
        };
        render-markdown = {
          enable = true;
          settings.render_modes = true;
        }; # better markdown support
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
