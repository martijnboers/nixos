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

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vimPlugins.sqlite-lua # smart-open
      tflint
      vale
      ruff
      eslint
    ];

    programs.nixvim =
      let
        helpers = config.lib.nixvim;
        mkHarBind = index: key: {
          inherit key;
          action = helpers.mkRaw ''function() require("harpoon"):list():select(${toString index}) end'';
        };
      in
      {
        enable = true;

        extraPlugins = with pkgs.vimPlugins; [
          smart-open-nvim
          (pkgs.vimUtils.buildVimPlugin {
            name = "openingh.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "Almo7aya";
              repo = "openingh.nvim";
              rev = "7cc8c897cb6b34d8ed28e99d95baccef609ed251";
              sha256 = "sha256-/FlNLWOSIrOYiWzAcgOdu9//QTorCDV1KWb+h6eqLwk=";
            };
          })
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
            key = "<Leader>d";
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
            key = "<Leader>e";
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
              desc = "Move line down 1";
              silent = true;
            };
          }
          {
            action = ":m -2<cr>";
            key = "<C-S-Up>";
            options = {
              desc = "Move line 1 up";
              silent = true;
            };
          }
          {
            action = ":m +1<cr>";
            key = "<C-S-Down>";
            options = {
              desc = "Move line down 1";
              silent = true;
            };
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
            background = {
              light = "dragon";
              dark = "dragon";
            };
          };
        };

        plugins = {
          which-key.enable = true; # popup with possible key combinations
          web-devicons.enable = true; # needed for other plugins
          noice.enable = true; # cmd popup input modal
          harpoon.enable = true; # no tabs?

          render-markdown = {
            enable = true;
            settings.render_modes = true;
          }; # better markdown support

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
              winbar = true;
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
              "<2-LeftMouse>" = "open";
              "<cr>" = "open";
              "<Left>" = "close_node";
              "<Right>" = "toggle_node";
              s = "open_vsplit";
              z = "close_all_nodes";
              R = "refresh";
              a = "add";
              d = "delete";
              r = "rename";
              y = "copy_to_clipboard";
              p = "paste_from_clipboard";
              c = "cut_to_clipboard";
              m = "move";
              "/" = "fuzzy_finder";
              ">" = "next_source";
              "<" = "prev_source";
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
          }; # left pane with files

          gitsigns = {
            enable = true;
            autoLoad = true;
          }; # gutter signs, blame, hunk previews

          barbecue = {
            enable = true;
            settings = {
              show_navic = false;
              show_modified = true;
              custom_section = helpers.mkRaw ''
                function()
                  local list = require("harpoon"):list()
                  local items = list.items 

                  if #items == 0 then
                    return ""
                  end

                  local display_parts = {}
                  for i, item_data in ipairs(items) do
                    local filepath = item_data.value
                    local filename = vim.fn.fnamemodify(filepath, ":t:r") 
                  table.insert(display_parts, string.format("[%d] %s", i, filename))
                  end

                return table.concat(display_parts, "  ") 
                end
              '';
            };
          }; # breadcrumbs at top of code files + cheeky harpoon helper

          telescope = {
            enable = true;
            enabledExtensions = [ "smart_open" ];
            keymaps = {
              "<Leader>f" = "live_grep";
              "<Leader>/" = "current_buffer_fuzzy_find";
              "<Leader>s" = "lsp_document_symbols";
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
                lsp_document_symbols = {
                  theme = "ivy";
                };
                live_grep = {
                  layout_strategy = "vertical";
                };
              };
            };
          }; # Find popups for files + more

          conform-nvim = {
            enable = true;
            settings = {
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                python = [ "black" ];
                lua = [ "stylua" ];
                html = [ "prettier" ];
                javascript = [ "prettier" ];
                javascriptreact = [ "prettier" ];
                typescript = [ "prettier" ];
                typescriptreact = [ "prettier" ];
                yaml = [ "yamlfmt" ];
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
                stylua.command = lib.getExe pkgs.stylua;
                prettier.command = lib.getExe pkgs.prettierd;
                yamlfmt.command = lib.getExe pkgs.yamlfmt;
              };
            };
          }; # formatters

          lint = {
            enable = true;
            lintersByFt = {
              nix = [ "nix" ];
              python = [ "ruff" ];
              javascript = [ "eslint" ];
              terraform = [ "tflint" ];
              text = [ "vale" ];
            };
          }; # code style linting

          treesitter = {
            enable = true;
            settings = {
              highlight.enable = true;
              indent.enable = true;
            };
          }; # Make vim understand syntax, but not like lsp

          lsp = {
            enable = true;
            keymaps = {
              lspBuf = {
                K = "hover";
                gD = "references";
                gd = "definition";
                gi = "implementation";
                gt = "type_definition";
                gr = "rename";
                ga = "code_action";
              };
            };
            servers = {
              bashls.enable = true;
              nixd.enable = true;
              html.enable = true;
              jsonls.enable = true;
              lua_ls.enable = true;
              terraformls.enable = true;
              pyright.enable = true;
              gopls.enable = true;
              ccls.enable = true;
              vtsls.enable = true; # Javascript (nice naming)
              yamlls.enable = true;
              docker_compose_language_service.enable = true;
            };
          }; # language servers

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
                "<C-e>" = [ "hide" ];
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
                "<C-y>" = [ "select_and_accept" ];
              };
              completion.documentation.auto_show = true;
              signature.enabled = true;
              sources.providers.buffer.score_offset = -7;
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

        clipboard = {
          providers.wl-copy.enable = true;
        };
      };
  };
}
