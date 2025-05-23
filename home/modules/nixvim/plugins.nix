{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vimPlugins.sqlite-lua # smart-open
      tflint
      vale
      ruff
      eslint
    ];

    programs.nixvim = {
      plugins = {
        which-key.enable = true; # popup with possible key combinations
        web-devicons.enable = true; # needed for other plugins
        noice.enable = true; # cmd popup input modal
        harpoon.enable = true; # no tabs?

        mini = {
          enable = true;
          modules = {
            surround = {
              mappings = {
                add = "sa";
                delete = "sd";
                replace = "sr";
              };
            }; # keybindings for adding quotes etc
            move = {
              mappings = {
                up = "<C-S-Up>";
                down = "<C-S-Down>";
                line_up = "<C-S-Up>";
                line_down = "<C-S-Down>";
              };
            }; # move line(s) up and down
          };
        };

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
            show_navic = true; # extended breadcrumbs
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
    };
  };
}
