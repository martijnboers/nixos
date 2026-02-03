{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;

  # Keymap Helper Functions {{{
  keymaps =
    let
      mk = args: {
        key = args.key;
        action = args.action;
        mode = args.modes;
        options = {
          inherit (args) desc;
          silent = true;
        };
      };
    in
    {
      inherit mk;
      cmd =
        args:
        mk (
          {
            modes = [
              "n"
              "v"
            ];
          }
          // args
          // {
            action = "<cmd>${args.command}<cr>";
          }
        );

      lua =
        args:
        mk (
          {
            modes = [
              "n"
              "v"
            ];
          }
          // args
          // {
            action = helpers.mkRaw "function() ${args.code} end";
          }
        );

      remap =
        args:
        mk (
          {
            modes = [ "n" ];
            desc = "remap from ${args.key} to ${args.to}";
          }
          // args
          // {
            action = args.to;
          }
        );

      git =
        args:
        mk (
          {
            modes = [
              "n"
              "v"
            ];
          }
          // args
          // {
            action = "<cmd>Git ${args.command}<cr>";
          }
        );

      gitChained =
        args:
        mk (
          {
            modes = [ "n" ];
          }
          // args
          // {
            action = builtins.concatStringsSep "" (map (cmd: "<cmd>Git ${cmd}<cr>") args.commands);
          }
        );

    };
  # }}}
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
    programs.nixvim = {
      enable = true;
      vimAlias = true;

      globals = {
        mapleader = " ";
      };

      # Vim Options {{{
      opts = {
        expandtab = true; # Use spaces instead of tabs
        shiftwidth = 2; # Size of an indent
        tabstop = 2; # Number of spaces tabs count for
        softtabstop = 2; # Number of spaces a <Tab> inserts in insert mode
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        cursorline = true; # Highlight the current line
        scrolloff = 8; # Keep 8 lines of context when scrolling vertically
        sidescrolloff = 8; # Keep 8 columns of context when scrolling horizontally
        splitbelow = true; # New horizontal splits go below
        splitright = true; # New vertical splits go to the right
        ignorecase = true; # Ignore case in search patterns
        smartcase = true; # Override ignorecase if search contains capitals
        swapfile = false; # Don't create cluttering .swp files
        undofile = true; # save undo history
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,globals";

        # Folding
        foldmethod = "marker"; # Use {{{ and }}} to define folds
        foldlevel = 0; # Close all marked folds by default
        foldenable = true; # Enable the feature
      };
      # }}}

      # Plugins {{{
      plugins = {
        noice.enable = true; # cmd popup input modal
        quicker.enable = true; # edit quickfix as buffer
        auto-session.enable = true; # save session
        markview.enable = true; # better markdown

        gitportal = {
          enable = true; # open gh or gitlab web
          settings.always_use_commit_hash_in_url = true;
        };

        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            files.enable = true; # file explorer
            extra.enable = true; # more picker sources
            icons.enable = true; # icons support for extensions
            surround.enable = true; # surround words with something
            git.enable = true; # :Git helper functions
            diff.enable = true; # gitsigns replacement
            visits.enable = true; # visited buffers

            hipatterns = {
              enable = true; # color color hexcodes
              highlighters.hex_color = helpers.mkRaw ''
                require('mini.hipatterns').gen_highlighter.hex_color(),
              '';
            };

            pick = {
              enable = true; # file picker
              mappings = {
                mark = "<C-CR>";
              };
            };

            move = {
              mappings = {
                up = "<C-S-Up>";
                down = "<C-S-Down>";
                line_up = "<C-S-Up>";
                line_down = "<C-S-Down>";
              };
            };

            statusline = {
              use_icons = true;
              content = {
                active = helpers.mkRaw ''
                  function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 200 })
                    local path          = MiniStatusline.section_filename({ trunc_width = 10 })

                    local n_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                    local n_warns  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

                    local s_errors = (n_errors > 0) and ("󰈸 " .. n_errors) or ""
                    local s_warns  = (n_warns > 0)  and ("󱅼 " .. n_warns) or ""

                    local recording = vim.fn.reg_recording()
                    local s_rec = (recording ~= "") and ("󰶇  " .. recording) or ""

                    local n_others = 0
                    local current_buf = vim.api.nvim_get_current_buf()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                      if vim.bo[buf].modified and vim.bo[buf].buflisted and buf ~= current_buf then
                        n_others = n_others + 1
                      end
                    end
                    local s_others = (n_others > 0) and ("● " .. n_others) or ""

                    local s_ok = (s_errors == "" and s_warns == "" and s_rec == "" and s_others == "") and " "

                    local current_line    = vim.fn.line('.')
                    local total_lines     = vim.fn.line('$')
                    local percentage_str  = string.format('%d%%%%', (total_lines > 0 and math.floor((current_line / total_lines) * 100)) or 0)

                    return MiniStatusline.combine_groups({
                      { hl = mode_hl,                  strings = { mode } },
                      '%<',
                      { hl = 'MiniStatuslineDevinfo',  strings = { percentage_str } },
                      { hl = 'MiniStatuslineLocation', strings = { path } },

                      '%=',
                      { hl = 'DiffChange',             strings = { s_others, s_rec } },
                      { hl = 'DiagnosticWarn',         strings = { s_warns } },
                      { hl = 'DiagnosticError',        strings = { s_errors } }, 
                      { hl = 'MiniStatuslineLocation', strings = { s_ok } },
                    })
                  end
                '';
              };
            };
          };
        };
      };
      # }}}

      keymaps = with keymaps; [
        # Picker / Fuzzy Finding {{{
        (lua {
          key = "<Leader>f";
          desc = "Find";
          code = "MiniPick.builtin.grep_live()";
          modes = [
            "n"
            "v"
          ];
        })
        (lua {
          key = "<Leader>l";
          desc = "Last picker";
          code = "MiniPick.builtin.resume()";
          modes = [
            "n"
            "v"
          ];
        })
        (lua {
          key = "<Leader>o";
          desc = "Files";
          code = "MiniPick.builtin.files()";
        })
        (lua {
          key = "<Leader>b";
          desc = "Find in buffers";
          code = "MiniExtra.pickers.visit_paths()";
        })
        (lua {
          key = "<Leader>/";
          desc = "Find in buffer lines";
          code = "MiniExtra.pickers.buf_lines({scope = 'current'})";
        })
        (lua {
          key = "<Leader>h";
          desc = "Find help pages";
          code = "MiniPick.builtin.help()";
        })
        (lua {
          key = "<Leader>x";
          desc = "Find errors";
          code = "MiniExtra.pickers.diagnostic()";
          modes = [
            "n"
            "v"
          ];
        })
        (lua {
          key = "<Leader>s";
          desc = "Find symbols";
          code = "MiniExtra.pickers.lsp({scope = 'document_symbol'})";
        })
        (lua {
          key = "<Leader>r";
          desc = "Show registers";
          code = "MiniExtra.pickers.registers()";
        })
        # }}}

        # File Explorer {{{
        (lua {
          key = "<Leader>e";
          desc = "Toggle MiniFiles";
          code = "if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end";
          modes = [
            "n"
            "v"
          ];
        })
        # }}}

        # Native Tab Management {{{
        (cmd {
          key = "<Leader>tn";
          command = "tabnew";
          desc = "New Tab (Workspace)";
        })
        (cmd {
          key = "<Leader>tc";
          command = "tabclose";
          desc = "Close Tab";
        })
        # }}}

        # Buffer Management {{{
        # Navigation
        (cmd {
          key = "<BS>";
          desc = "Go to alternate buffer";
          command = "b #";
        })
        (remap {
          key = "x";
          desc = "Close window";
          to = "<C-w>q";
        })
        (remap {
          key = "<Tab>";
          to = "<C-w>";
        })
        # }}}

        # Git Operations {{{
        (git {
          key = "gb";
          desc = "Git blame";
          command = "log --patch -- %";
        })
        (lua {
          key = "gb";
          desc = "Git blame";
          code = "MiniGit.show_at_cursor()";
          modes = [ "v" ];
        })
        (git {
          key = "glg";
          desc = "Git log";
          command = "log --patch --max-count=100";
        })
        (lua {
          key = "glc";
          desc = "Git commits";
          code = "MiniExtra.pickers.git_commits()";
        })
        (cmd {
          key = "go";
          desc = "Open file in source control";
          command = "GitPortal";
        })
        (lua {
          key = "g\\";
          desc = "Show buffer changes";
          code = "MiniDiff.toggle_overlay()";
        })
        (lua {
          key = "gu";
          desc = "Unstaged hunks";
          code = "MiniExtra.pickers.git_hunks()";
        })
        (lua {
          key = "gs";
          desc = "Staged hunks";
          code = "MiniExtra.pickers.git_hunks({scope = \"staged\"})";
        })
        (git {
          key = "<Leader>cc";
          desc = "Git commit --verbose";
          command = "commit";
        })
        (gitChained {
          key = "<Leader>ca";
          desc = "Git commit all";
          commands = [
            "add ."
            "commit --verbose"
          ];
        })
        (gitChained {
          key = "<Leader>cf";
          desc = "fixup";
          commands = [
            "add ."
            "commit --amend --no-edit"
          ];
        })
        (git {
          key = "<Leader>pl";
          desc = "Git pull";
          command = "pull --rebase";
        })
        (git {
          key = "<Leader>pp";
          desc = "Git push";
          command = "push";
        })
        (git {
          key = "<Leader>pf";
          desc = "Git push force";
          command = "push --force-with-lease --force-if-includes";
        })
        # }}}

        # Quality of Life / Utilities {{{
        # Smooth scrolling (center cursor)
        (remap {
          key = "<C-u>";
          to = "<C-u>zz";
        })
        (remap {
          key = "<C-d>";
          to = "<C-d>zz";
        })
        (mk {
          key = "<Leader>y";
          desc = "Add to sytem clipboard";
          action = ''"+y'';
          modes = [ "v" ];
        })
        (cmd {
          key = "<Leader>y";
          desc = "Add whole file to sytem clipboard";
          command = "%y+";
          modes = [ "n" ];
        })
        # Fix for Tab mapping breaking Ctrl-i
        (remap {
          key = "<C-i>";
          to = "<C-i>";
        })
        (lua {
          key = "-";
          desc = "Decrease window size";
          modes = [ "n" ];
          code = # lua
            ''
              if vim.fn.winnr("$") == 1 then return end

              local width = vim.api.nvim_win_get_width(0)
              local total_width = vim.o.columns

              if width >= total_width - 2 then
                vim.cmd("resize -3")
              else
                vim.cmd("vertical resize -3")
              end
            '';
        })
        (lua {
          key = "+";
          desc = "Increase window size";
          modes = [ "n" ];
          code = # lua
            ''
              if vim.fn.winnr("$") == 1 then return end

              local width = vim.api.nvim_win_get_width(0)
              local total_width = vim.o.columns

              if width >= total_width - 2 then
                vim.cmd("resize +3")
              else
                vim.cmd("vertical resize +3")
              end
            '';
        })
        # }}}
      ];

      # Diagnostics & Colorschemes {{{
      diagnostic.settings = {
        virtual_text = false;
        signs = false;
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
      # }}}

      # Auto Commands {{{
      autoCmd = [
        {
          event = "FileType";
          pattern = [
            "git"
            "diff"
          ];
          callback = helpers.mkRaw ''
            function()
              vim.opt_local.foldmethod = "expr"
              vim.opt_local.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
              vim.opt_local.foldlevel = 0
              vim.keymap.set("n", "<CR>", "zA", { buffer = true, silent = true, desc = "Toggle fold recursively" })
            end
          '';
        }
      ];
      # }}}

      clipboard = {
        providers.wl-copy.enable = true;
      };
    };
  };
}
