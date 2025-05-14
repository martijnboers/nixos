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
      tflint
      vale
      ruff
    ];

    programs.nixvim =
      let
        helpers = config.lib.nixvim;

        mkHarBind = index: key: {
          inherit key;
          action = helpers.mkRaw ''function() require("harpoon"):list():select(${builtins.toString index}) end'';
        };

      in
      {
        enable = true;

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

        keymaps = [
          {
            action = "<cmd>Neotree reveal toggle<cr>";
            key = "<Leader>d";
            options.desc = "toggle file explorer";
          }

          # git stuff
          {
            action = "<cmd>Gitsigns blame<cr>";
            key = "<Leader>gB";
            options.desc = "Git blame";
          }
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
            action = "<cmd>Telescope git_commits<cr>";
            key = "<Leader>gf";
          }
          {
            action = "<cmd>Telescope git_branches<cr>";
            key = "<Leader>gF";
          }
          {
            action = "<cmd>Telescope git_status<cr>";
            key = "<Leader>gs";
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

          # AI keybindings
          {
            action = ":ParrotChatNew<cr>";
            key = "<Leader>cn";
            mode = [
              "v"
              "n"
            ];
            options = {
              desc = "Start new chat";
              silent = true;
            };
          }
          {
            action = ":ParrotChatPaste<cr>";
            key = "<Leader>ca";
            mode = [ "v" ];
            options = {
              desc = "Paste into chat";
              silent = true;
            };
          }
          {
            action = "<cmd>ParrotChatFinder<cr>";
            key = "<Leader>cf";
            options.desc = "Find chats";
          }
          {
            action = ":ParrotRewrite<cr>";
            key = "<Leader>cr";
            mode = [ "v" ];
            options = {
              desc = "Rewrite section";
              silent = true;
            };
          }
          {
            action = ":ParrotAppend<cr>";
            key = "<Leader>cc";
            mode = [ "v" ];
            options = {
              desc = "Change to spec of prompt";
              silent = true;
            };
          }
          {
            action = ":ParrotImplement<cr>";
            key = "<Leader>ci";
            mode = [ "v" ];
            options = {
              desc = "Implement spec in visual";
              silent = true;
            };
          }

          # Setup for bigger plugins
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
            action = helpers.mkRaw ''
              function() local harpoon = require('harpoon') harpoon.ui:toggle_quick_menu(harpoon:list()) end
            '';
            key = "<C-h>";
            options.desc = "Harpoon menu";
          }
          (mkHarBind 1 "<C-j>")
          (mkHarBind 2 "<C-k>")
          (mkHarBind 3 "<C-l>")
          (mkHarBind 4 "<C-;>")
          {
            action = helpers.mkRaw ''
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

        diagnostic.settings.virtual_lines.only_current_line = true; # enable lsp-lines error messages

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
          nvim-autopairs.enable = true; # automaticly close { [ etc ] };
          lsp-lines.enable = true; # diagnostics inline
          harpoon.enable = true; # no tabs?

          render-markdown = {
            enable = true;
            settings.render_modes = true;
          }; # better markdown support

          neo-tree = {
            enable = true;
            hideRootNode = true; # don't show from opened folder
            closeIfLastWindow = true;
            buffers.followCurrentFile.enabled = true;
            filesystem.followCurrentFile.enabled = true;
          }; # left pane with files

          gitsigns = {
            enable = true;
            autoLoad = true;
          }; # gutter signs, blame, hunk previews

          parrot = {
            enable = true;
            settings = {
              cmd_prefix = "Parrot";
              providers = {
                gemini = {
                  api_key = helpers.mkRaw "os.getenv 'GOOGLE_LLM_API_KEY'";
                  topic.model = "gemini-2.5-flash-preview-04-17";
                  models = [
                    "gemini-2.5-flash-preview-04-17"
                    "gemini-2.5-pro-preview-05-06"
                  ];
                };
              };
            };
          }; # ai assistance

          barbecue = {
            enable = true;
            settings = {
              show_modified = true;
              custom_section = helpers.mkRaw
                ''
                  function()
                    local list = require("harpoon"):list()
                    local items = list.items 

                    if #items == 0 then
                      return ""
                    end

                    local display_parts = {}
                    for i, item_data in ipairs(items) do
                      local filepath = item_data.value
                      local filename = vim.fn.fnamemodify(filepath, ":t") -- :t gets the tail (filename.ext)
                    table.insert(display_parts, string.format("[%d] %s", i, filename))
                    end

                  return table.concat(display_parts, "  ") 
                  end
                '';
            };
          }; # breadcrumbs at top of code files + cheeky harpoon helper

          telescope = {
            enable = true;
            keymaps = {
              "<Leader>e" = "find_files";
              "<Leader>f" = "live_grep";
              "<Leader>/" = "current_buffer_fuzzy_find";
              "<Leader>s" = "lsp_document_symbols";
              "<Leader>h" = "help_tags";
              "<Leader>x" = "diagnostics";
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
                lua = [ "stylua" ];
                html = [ "prettier" ];
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
                prettier.command = lib.getExe pkgs.nodePackages.prettier;
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
            ];
          }; # rice
        };

        clipboard = {
          providers.wl-copy.enable = true;
        };
      };
  };
}
