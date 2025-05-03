{
  lib,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    tflint
    vale
    ruff
  ];

  programs.nixvim =
    let
      helpers = config.lib.nixvim;
    in
    {
      enable = true;

      clipboard = {
        providers.wl-copy.enable = true;
      };

      keymaps =
        let
          mkHarBind = index: key: {
            inherit key;
            action = helpers.mkRaw ''function() require("harpoon"):list():select(${builtins.toString index}) end'';
          };
        in
        [
          {
            action = "<cmd>Neotree reveal toggle<cr>";
            key = "<Leader>d";
            options.desc = "toggle file explorer";
          }
          {
            action = "<cmd>Gitsigns blame<cr>";
            key = "<Leader>gB";
            options.desc = "Git blame";
          }
          {
            action = "<cmd>Gitsigns blame_line<cr>";
            key = "<Leader>gb";
            options.desc = "Git blame current line";
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
            action =
              helpers.mkRaw # lua
                ''
                  function() require("harpoon"):list():add() end
                '';
            key = "<Leader>a";
            options.desc = "Add to harpoon";
          }
          {
            action =
              helpers.mkRaw # lua
                ''
                  function() local harpoon = require('harpoon') harpoon.ui:toggle_quick_menu(harpoon:list()) end
                '';
            key = "<C-h>";
            options.desc = "Harpoon menu";
          }
          (mkHarBind 1 "<C-j>")
          (mkHarBind 2 "<C-k>")
          (mkHarBind 3 "<C-l>")
          {
            action =
              helpers.mkRaw # lua
                ''
                  function() require("conform").format({ 
                    lsp_fallback = true, async = false, timeout_ms = 500,
                  }) end
                '';
            mode = [
              "v"
              "n"
            ];

            key = "<Leader>=";
            options.desc = "format selection or whole buffer";
          }
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
            action = "<C-w>W";
            key = "<S-Tab>";
            options.desc = "prev buffer";
          }
          {
            action = "<cmd>bd<cr>";
            key = "x";
            options.desc = "close buffer";
          }
        ];

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
        laststatus = 0; # hide bottom bar, noice does this
        smartindent = false; # done by treesitter
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"; # stuff for auto-session
      };

      diagnostic.settings = {
        virtual_text = false; # disable default error messages
        virtual_lines.only_current_line = true; # enable lsp-lines error messages
      };

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          dimInactive = true;
          background = {
            light = "dragon";
            dark = "dragon";
          };
        };
      };
      plugins = {
        which-key.enable = true; # popup with possible key combinations
        barbecue = {
          enable = true; # breadcrumbs at top of code files
          settings = {
            show_modified = true;
            show_navic = true;
            exclude_filetypes = [
              "netrw"
              "toggleterm"
            ];
          };
        };
        web-devicons.enable = true; # needed for another plugins
        noice.enable = true; # cmd popup input modal
        comment.enable = true; # comments visual lines
        render-markdown.enable = true; # better markdown support
        lsp-lines.enable = true; # diagnostics inline

        auto-session = {
          enable = true; # re-open all buffers
          settings.root_dir = "/tmp/nvim-sessions"; # auto-remove on startup
        };

        neo-tree = {
          enable = true; # left pane with files
          hideRootNode = true; # don't show from opened folder
          closeIfLastWindow = true; # close vim if no more text buffers
        };

        harpoon = {
          enable = true;
          enableTelescope = true;
        }; # oke maybe no tabs

        gitsigns = {
          enable = true;
          autoLoad = true;
        }; # gutter signs, blame, hunk previews

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        }; # Syntax highlighting

        telescope = {
          enable = true;
          keymaps = {
            "<Leader>e" = "find_files";
            "<Leader>f" = "live_grep";
            "<Leader>/" = "current_buffer_fuzzy_find";
            "<Leader>s" = "lsp_document_symbols";
            "<Leader>gf" = "git_commits";
            "<Leader>gF" = "git_branches";
            "<Leader>gs" = "git_status";
          };
          settings = {
            pickers = {
              lsp_document_symbols = {
                theme = "ivy";
              };
              find_files = {
                theme = "ivy";
              };
              buffers = {
                sort_mru = true; # https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L1465
              };
            };
          };
        }; # file + buffer finder popup

        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              nix = [ "nixfmt" ];
              python = [ "black" ];
              bash = [
                "shellcheck"
                "shellharden"
                "shfmt"
              ];
              "_" = [
                "trim_whitespace"
                "trim_newlines"
              ];
            };
            formatters = {
              black.command = lib.getExe pkgs.black;
              shellcheck.command = lib.getExe pkgs.shellcheck;
              shfmt.command = lib.getExe pkgs.shfmt;
              shellharden.command = lib.getExe pkgs.shellharden;
              nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
            };
          };
        }; # formatters

        lint = {
          enable = true;
          lintersByFt = {
            nix = [ "nix" ];
            python = [ "ruff" ];
            terraform = [
              "tflint"
            ];
            text = [
              "vale"
            ];
          };
        }; # code style linting

        blink-cmp = {
          enable = true;
          settings = {
            enabled = helpers.mkRaw ''
              function()
                return vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
              end
            '';
            keymap = {
              "<C-b>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-e>" = [
                "hide"
              ];
              "<C-f>" = [
                "scroll_documentation_down"
                "fallback"
              ];
              "<C-n>" = [
                "select_next"
                "fallback"
              ];
              "<C-p>" = [
                "select_prev"
                "fallback"
              ];
              "<C-space>" = [
                "show"
                "show_documentation"
                "hide_documentation"
              ];
              "<C-y>" = [
                "select_and_accept"
              ];
            };
            appearance = {
              nerd_font_variant = "mono";
              use_nvim_cmp_as_default = true;
            };
            completion = {
              accept = {
                auto_brackets = {
                  enabled = true;
                  semantic_token_resolution = {
                    enabled = false;
                  };
                };
              };
              documentation = {
                auto_show = true;
              };
            };
            signature = {
              enabled = true;
            };
            sources = {
              cmdline = [ ];
              providers = {
                buffer = {
                  score_offset = -7;
                };
                lsp = {
                  fallbacks = [ ];
                };
              };
            };
          };
        };

        lsp = {
          enable = true;
          keymaps = {
            lspBuf = {
              K = "hover";
              gD = "references";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
            };
          };
          servers = {
            bashls.enable = true;
            nixd.enable = true;
            html.enable = true;
            jsonls.enable = true;
            terraformls.enable = true;
            pyright.enable = true;
            gopls.enable = true;
            ccls.enable = true;
            docker_compose_language_service.enable = true;
          };
        };

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
          ];
        }; # rice
      };
    };
}
