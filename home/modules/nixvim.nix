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

  mkLuaKeymap = key: desc: luaCode: {
    inherit key;
    action = helpers.mkRaw "function() ${luaCode} end";
    options.desc = desc;
  };

  mkLuaKeymapModes = key: desc: modes: luaCode: {
    inherit key;
    mode = modes;
    action = helpers.mkRaw "function() ${luaCode} end";
    options.desc = desc;
  };

  mkCmdKeymap = key: desc: cmd: {
    inherit key;
    action = "<cmd>${cmd}<cr>";
    options.desc = desc;
  };

  mkGitKeymap = key: desc: gitCmd: {
    inherit key;
    action = ":Git ${gitCmd}<cr>";
    options = {
      inherit desc;
      silent = true;
    };
  };

  mkGitChainedKeymap = key: desc: commands: {
    inherit key;
    action = builtins.concatStringsSep "" (map (cmd: "<cmd>Git ${cmd}<cr>") commands);
    options = {
      inherit desc;
      silent = true;
    };
  };

  mkSimpleRemap = key: action: {
    inherit key action;
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
        termguicolors = true; # more colors, makes linenumber color work
        cursorline = true; # show highlight under cursor
      };

      plugins = {
        noice.enable = true; # cmd popup input modal
        auto-session.enable = true; # auto-restore sessions on startup
        quicker.enable = true; # edit quickfix as buffer

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

      keymaps = [
        # ============================================
        # Picker / Fuzzy Finding
        # ============================================
        (mkLuaKeymapModes "<Leader>f" "Find" [ "n" "v" ] "MiniPick.builtin.grep_live()")
        (mkLuaKeymap "<Leader>o" "Files" "MiniPick.builtin.files()")
        (mkLuaKeymap "<Leader>b" "Find in buffers" "MiniPick.builtin.buffers()")
        (mkLuaKeymap "<Leader>/" "Find in buffer lines" "MiniExtra.pickers.buf_lines()")
        (mkLuaKeymap "<Leader>h" "Find help pages" "MiniPick.builtin.help()")
        (mkLuaKeymapModes "<Leader>x" "Find errors" [ "n" "v" ] "MiniExtra.pickers.diagnostic()")
        (mkLuaKeymap "<Leader>s" "Find symbols" "MiniExtra.pickers.lsp({scope = 'document_symbol'})")
        (mkLuaKeymap "<Leader>r" "Show registers" "MiniExtra.pickers.registers()")

        # ============================================
        # File Explorer
        # ============================================
        (mkLuaKeymapModes "<Leader>e" "Toggle MiniFiles" [
          "n"
          "v"
        ] "if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end")

        # ============================================
        # Buffer Management
        # ============================================
        # Navigation
        (mkCmdKeymap "<Left>" "Go to prev buffer" "BufferPrevious")
        (mkCmdKeymap "<Right>" "Go to next buffer" "BufferNext")
        (mkGotoBuffer 1)
        (mkGotoBuffer 2)
        (mkGotoBuffer 3)

        # Moving buffers
        (mkCmdKeymap "<C-S-Left>" "Move buffer left" "BufferMovePrevious")
        (mkCmdKeymap "<C-S-Right>" "Move buffer to the right" "BufferMoveNext")

        # Closing buffers
        (mkLuaKeymap "x" "close buffer" "vim.api.nvim_buf_delete(0, {})")
        (mkCmdKeymap "X" "Close all but pinned or current" "BufferCloseAllButCurrentOrPinned")

        # Pinning
        (mkCmdKeymap "<Leader>a" "Pin buffer" "BufferPin")

        # Window navigation
        (mkSimpleRemap "<Tab>" "<C-w>w")
        (mkSimpleRemap "<S-Tab>" "<C-w>W")

        # ============================================
        # Git Operations
        # ============================================
        # Viewing / Blame
        {
          key = "gb";
          mode = [ "n" ];
          action = ":Pick git_commits path='%'<cr>";
          options.desc = "Git blame";
        }
        (mkLuaKeymapModes "gb" "Git blame" [ "v" ] "MiniGit.show_at_cursor()")
        (mkGitKeymap "glg" "Git log" "log --stat --max-count=200")

        # Diff / Hunks
        (mkLuaKeymap "gt" "Show buffer changes" "MiniDiff.toggle_overlay()")
        (mkLuaKeymap "gu" "Unstaged hunks" "MiniExtra.pickers.git_hunks()")
        (mkLuaKeymap "gs" "Staged hunks" "MiniExtra.pickers.git_hunks({scope = \"staged\"})")

        # Commits
        (mkGitKeymap "<Leader>cc" "Git commit --verbose" "commit")
        (mkGitChainedKeymap "<Leader>ca" "Git commit all" [
          "add ."
          "commit --verbose"
        ])
        (mkGitChainedKeymap "<Leader>cf" "fixup" [
          "add ."
          "commit --amend --no-edit"
        ])

        # Push / Pull
        (mkGitKeymap "<Leader>pl" "Git pull" "pull --rebase")
        (mkGitKeymap "<Leader>pp" "Git push" "push")
        (mkGitKeymap "<Leader>pf" "Git push force" "push --force-with-lease --force-if-includes")

        # GitHub integration
        (mkCmdKeymap "<Leader>go" "Open file in source control" "OpenInGHFile")
        {
          key = "<Leader>go";
          mode = [ "v" ];
          action = ":OpenInGHFileLines<cr>"; # has to be : for range to work
          options.silent = true;
        }

        # ============================================
        # Quality of Life / Utilities
        # ============================================
        # Smooth scrolling (center cursor)
        (mkSimpleRemap "<C-u>" "<C-u>zz")
        (mkSimpleRemap "<C-d>" "<C-d>zz")

        # Clipboard operations
        {
          key = "<Leader>y";
          mode = [ "v" ];
          action = "\"+y";
          options = {
            desc = "Add to sytem clipboard";
            silent = true;
          };
        }
        {
          key = "<Leader>y";
          mode = [ "n" ];
          action = "<cmd>%y+<cr>";
          options = {
            desc = "Add whole file to sytem clipboard";
            silent = true;
          };
        }

        # Fix for Tab mapping breaking Ctrl-i
        (mkSimpleRemap "<C-i>" "<C-i>")
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
