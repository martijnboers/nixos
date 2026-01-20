{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;

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
            modes = [ "n" ];
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

      opts = {
        expandtab = true; # Use spaces instead of tabs (Fixes nixfmt exploding)
        shiftwidth = 2; # Size of an indent
        tabstop = 2; # Number of spaces tabs count for
        softtabstop = 2; # Number of spaces a <Tab> inserts in insert mode
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers (for easy jumps)
        termguicolors = true; # Enable 24-bit RGB colors (Required for Kanagawa)
        cursorline = true; # Highlight the current line
        scrolloff = 8; # Keep 8 lines of context when scrolling vertically
        sidescrolloff = 8; # Keep 8 columns of context when scrolling horizontally
        splitbelow = true; # New horizontal splits go below
        splitright = true; # New vertical splits go to the right
        ignorecase = true; # Ignore case in search patterns
        smartcase = true; # Override ignorecase if search contains capitals
        swapfile = false; # Don't create cluttering .swp files
        autoread = true; # Automatically reload files changed outside vim
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal";
      };

      plugins = {
        noice.enable = true; # cmd popup input modal
        auto-session.enable = true; # auto-restore sessions on startup
        quicker.enable = true; # edit quickfix as buffer
        hex.enable = true; # hexeditor

        gitportal = {
          enable = true; # open gh or gitlab web
          settings.always_use_commit_hash_in_url = true;
        };

        barbar = {
          enable = true; # tabs, as understood by any other editor.
          settings = {
            clickable = true;
            animations = false;
            auto_hide = 1;
            exclude_ft = [ "qf" ];
            icons = {
              button = false;
              preset = "default";
              filetype.enabled = false;
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

        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            files.enable = true; # file explorer
            pick.enable = true; # file picker
            extra.enable = true; # more picker sources
            icons.enable = true; # icons support for extensions
            surround.enable = true; # surround words with something
            git.enable = true; # :Git helper functions
            diff.enable = true; # gitsigns replacement

            hipatterns = {
              enable = true; # color color hexcodes
              highlighters.hex_color = helpers.mkRaw ''
                require('mini.hipatterns').gen_highlighter.hex_color(),
              '';
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
              use_icons = false;
              content = {
                active = helpers.mkRaw ''
                  function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 200 })
                    local diff          = MiniStatusline.section_diff({ icon = "  ", trunc_width = 70 })
                    local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 70 })
                    local path          = MiniStatusline.section_filename({ trunc_width = 10 })

                    -- Calculate the percentage of the current line in the file
                    local current_line = vim.fn.line('.')
                    local total_lines = vim.fn.line('$')
                    local percentage = math.floor((current_line / total_lines) * 100)
                    local percentage_str = string.format('%d%%%%', (total_lines > 0 and math.floor((current_line / total_lines) * 100)) or 0)

                    return MiniStatusline.combine_groups({
                      { hl = mode_hl,               	strings = { mode } },
                      '%<',
                      { hl = 'MiniStatuslineDevinfo',	strings = { percentage_str } },
                      { hl = 'MiniStatuslineLocation', 	strings = { path } },
                      '%=',
                      { hl = 'MiniStatuslineFileinfo', 	strings = { fileinfo } },
                      { hl = 'MiniStatuslineDiff',  	strings = {  diff } },
                    })
                  end
                '';
              };
            };
          };
        };
      };

      keymaps = with keymaps; [
        # ============================================
        # Picker / Fuzzy Finding
        # ============================================
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
          key = "<Leader>o";
          desc = "Files";
          code = "MiniPick.builtin.files()";
        })
        (lua {
          key = "<Leader>b";
          desc = "Find in buffers";
          code = "MiniPick.builtin.buffers()";
        })
        (lua {
          key = "<Leader>/";
          desc = "Find in buffer lines";
          code = "MiniExtra.pickers.buf_lines()";
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

        # ============================================
        # File Explorer
        # ============================================
        (lua {
          key = "<Leader>e";
          desc = "Toggle MiniFiles";
          code = "if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end";
          modes = [
            "n"
            "v"
          ];
        })

        # ============================================
        # Buffer Management
        # ============================================
        # Navigation
        (cmd {
          key = "<Left>";
          desc = "Go to prev buffer";
          command = "BufferPrevious";
        })
        (cmd {
          key = "<Right>";
          desc = "Go to next buffer";
          command = "BufferNext";
        })
        (cmd {
          key = "<C-S-Left>";
          desc = "Move buffer left";
          command = "BufferMovePrevious";
        })
        (cmd {
          key = "<C-S-Right>";
          desc = "Move buffer to the right";
          command = "BufferMoveNext";
        })
        (cmd {
          key = "x";
          desc = "Close buffer";
          command = "bd";
        })
        (cmd {
          key = "X";
          desc = "Close all but pinned or current";
          command = "BufferCloseAllButCurrentOrPinned";
        })
        (cmd {
          key = "<Leader>a";
          desc = "Pin buffer";
          command = "BufferPin";
        })
        (remap {
          key = "<Tab>";
          to = "<C-w>";
        })

        # ============================================
        # Git Operations
        # ============================================
        (lua {
          key = "gb";
          desc = "Git blame";
          code = "MiniExtra.pickers.git_commits({ path=vim.fn.expand('%') })";
          modes = [ "n" ];
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
          command = "log --stat --max-count=200";
        })
        (lua {
          key = "gt";
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
        (cmd {
          key = "<Leader>go";
          desc = "Open file in source control";
          command = "GitPortal";
        })

        # ============================================
        # Quality of Life / Utilities
        # ============================================
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
      ];

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

      clipboard = {
        providers.wl-copy.enable = true;
      };
    };
  };
}
