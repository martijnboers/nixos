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
    ./dap.nix
    ./lsp.nix
    ./snip.nix
  ];

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      vimAlias = true;

      globals = {
        mapleader = " ";
      };

      opts = {
        expandtab = true; # Use spaces instead of tabs
        shiftwidth = 2; # Size of an indent
        tabstop = 2; # Number of spaces tabs count for
        softtabstop = 2; # Number of spaces a <Tab> inserts in insert mode
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        ignorecase = true; # Ignore case in search patterns
        smartcase = true; # Override ignorecase if search contains capitals
        swapfile = false; # Don't create cluttering .swp files
        undofile = true; # Save undo history
        cmdheight = 0; # hide command line
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,globals";
        smoothscroll = true;

        # Spelling
        spell = false;
        spelllang = "nl"; # Harper not supported yet
        spellsuggest = "best,9";

        # Folding
        foldenable = true;
        foldlevel = 20;
        foldmethod = "expr";
        foldexpr = "v:lua.vim.lsp.foldexpr()";

        # Completion
        wildoptions = "pum"; # popup menu for wildmenu
        wildmode = "longest:full,full"; # Complete longest common string, then each full match
        winborder = "single";
        completeopt = "menu,menuone,noinsert"; # Show menu, autoselect first, don't auto-insert
        complete = "."; # Current buffer only
        infercase = true; # Infer case for completion
        pumheight = 15; # Max items in completion menu
        pumwidth = 30; # Minimum width of completion menu
      };

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          dimInactive = true;
          transparent = true;
          colors.theme.all.ui.bg_gutter = "none";
          commentStyle.italic = true;
          background = {
            light = "wave";
            dark = "dragon";
          };
          overrides = # lua
            ''
              function(colors)
                local theme = colors.theme
                local palette = colors.palette
                return {
                  -- Inactive window contrast 
                  NormalNC = { bg = palette.sumiInk0 },

                  -- Completion popups 
                  Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                  PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                  PmenuKind = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p1 },
                  PmenuKindSel = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p2 },
                  PmenuExtra = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p1 },
                  PmenuExtraSel = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p2 },
                  PmenuSbar = { bg = theme.ui.bg_m1 },
                  PmenuThumb = { bg = theme.ui.bg_p2 },

                  -- Status line icons (diagnostic colors from theme)
                  MiniStatuslineIconWarn = { fg = theme.diag.warning, bg = "none" },
                  MiniStatuslineIconError = { fg = theme.diag.error, bg = "none" },
                  
                  -- Error/warning indicator icon with dynamic background
                  StatuslineErrorIcon = { fg = theme.diag.error, bg = "none" },
                  StatuslineNormalIcon = { fg = theme.ui.fg, bg = "none" },
                }
              end
            '';
        };
      };
      diagnostic.settings = {
        virtual_text = false;
        signs = false;
        virtual_lines = {
          enable = true;
          current_line = true;
        };
      };

      plugins = {
        markview.enable = true; # better Markdown
        friendly-snippets.enable = true; # community snippets

        neoscroll = {
          enable = true;
          settings = {
            duration_multiplier = 0.8;
            mappings = [
              "<C-u>"
              "<C-d>"
              "<C-f>"
              "<C-b>"
              "zz"
            ];
            hide_cursor = true;
            easing = "quadratic";
          };
        };

        gitportal = {
          enable = true; # open gh or gitlab web
          settings.always_use_commit_hash_in_url = true;
        };

        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            files.enable = true; # file explorer
            pick.enable = true; # file picker
            extra.enable = true; # more picker sources
            icons.enable = true; # icons support for extensions
            git.enable = true; # :git helper functions
            diff.enable = true; # gitsigns replacement
            completion.enable = true; # autocomplete
            notify.enable = true; # vim.notify capture

            surround = {
              enable = true; # surround words with something
              mappings = {
                add = "<Leader>qa"; # 'quote add'
                delete = "<Leader>qd";
                replace = "<Leader>qr";
                find = "";
                find_left = "";
                highlight = "";
              };
            };

            sessions = {
              enable = true;
              autoread = true;
              autowrite = true;
              file = ".nvim.session";
              # allow deleting current session
              force.delete = true;
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
                    local full_filename = vim.fn.pathshorten(vim.fn.expand('%:~:.'))

                    local n_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                    local n_warns  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                    local s_rec = vim.fn.reg_recording() ~= "" and ( vim.fn.reg_recording()) .. "  " or ""

                    local n_unwritten = 0
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                      if vim.bo[buf].modified and vim.bo[buf].buflisted then n_unwritten = n_unwritten + 1 end
                    end

                    local ahead, behind, dirty = vim.b.git_ahead or 0, vim.b.git_behind or 0, vim.b.git_dirty
                    local s_arrows = (ahead > 0 and ("↑" .. ahead) or "") .. (ahead > 0 and behind > 0 and " " or "") .. (behind > 0 and ("↓" .. behind) or "")
                    
                    local s_state = (n_unwritten > 0) and "●" or (dirty) and "◌" or ""
                    local s_git = s_state .. (s_state ~= "" and s_arrows ~= "" and " " or "") .. s_arrows
                    
                    local total_lines = vim.fn.line('$')
                    local percentage = total_lines > 0 and math.floor((vim.fn.line('.') / total_lines) * 100) or 0

                    local navic = require('nvim-navic')
                    local context = navic.is_available() and navic.get_location() or ""
                    local location_str = full_filename .. (context ~= "" and " › " .. context or "")

                    local groups = {
                        { hl = mode_hl,                  strings = { mode } },
                        { hl = 'MiniStatuslineDevinfo',  strings = { percentage .. '%%' } },
                        { hl = 'MiniStatuslineLocation', strings = { location_str } },
                        '%=', '%<',
                        { hl = 'MiniStatuslineDevinfo',  strings = { s_rec } },
                    }
                    
                    if s_git ~= "" then table.insert(groups, { hl = 'MiniStatuslineDevinfo', strings = { s_git } }) end
                    
                    local icon_hl = (n_errors > 0) and 'StatuslineErrorIcon' or 'StatuslineNormalIcon'
                    local icon_str = (n_errors > 0) and ("󰈸 " .. n_errors) or " "
                    table.insert(groups, { hl = icon_hl, strings = { icon_str } })

                    return MiniStatusline.combine_groups(groups)
                  end
                '';
              };
            };
          };
        };
      };

      autoCmd =
        let
          updateGit = helpers.mkRaw ''
            function(args)
              local buf = args.buf or vim.api.nvim_get_current_buf()
              local summary = vim.b[buf].minigit_summary
              if not summary or not summary.repo then return end

              vim.system(
                { "git", "status", "--porcelain=v2", "--branch" },
                { text = true, cwd = summary.root },
                function(obj)
                  local ahead, behind, dirty = 0, 0, false
                  
                  if obj.code == 0 and obj.stdout then
                    local a, b = obj.stdout:match("# branch%.ab %+(%d+) %-(%d+)")
                    ahead, behind = a and tonumber(a) or 0, b and tonumber(b) or 0
                    dirty = obj.stdout:find("\n[^#]") ~= nil
                  end

                  vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                      vim.b[buf].git_ahead = ahead
                      vim.b[buf].git_behind = behind
                      vim.b[buf].git_dirty = dirty
                      vim.cmd("redrawstatus")
                    end
                  end)
                end
              )
            end
          '';

        in
        [
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
              end
            '';
          }

          {
            event = "User";
            pattern = [
              "MiniGitUpdated"
              "MiniDiffUpdated"
              "MiniGitCommandDone"
            ];
            callback = updateGit;
          }
          {
            event = [
              "FocusGained"
              "BufEnter"
            ];
            callback = updateGit;
          }
          {
            event = "CursorMoved";
            callback = helpers.mkRaw ''
              function()
                if vim.v.hlsearch == 0 then return end
                local bufnr = vim.api.nvim_get_current_buf()
                
                -- Clear previous extmarks
                local ns = vim.api.nvim_create_namespace('searchcount')
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
                
                local pos = vim.fn.searchpos(vim.fn.getreg('/'), 'ncw')
                if pos[1] == 0 then return end
                
                local current = vim.fn.searchcount({maxcount = 1000, timeout = 100})
                if current.current > 0 and current.total > 0 then
                  local text = string.format(" -- [%d/%d]", current.current, current.total)
                  vim.api.nvim_buf_set_extmark(bufnr, ns, pos[1] - 1, pos[2] - 1, {
                    virt_text = {{text, "Comment"}},
                    virt_text_pos = "eol",
                    priority = 100,
                  })
                end
              end
            '';
          }
        ];

      clipboard = {
        providers.wl-copy.enable = true;
      };

      keymaps = with keymaps; [
        # Picker / Fuzzy Finding
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
          code = "MiniPick.builtin.buffers()";
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

        # terminal
        {
          mode = "t";
          key = "<esc><esc>";
          action = ''C-\><c-n>'';
          options = {
            silent = true;
            desc = "Git Revert selected hunk";
          };
        }

        # File Explorer
        (lua {
          key = "<Leader>e";
          desc = "Toggle MiniFiles";
          code = "if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end";
          modes = [
            "n"
            "v"
          ];
        })

        (git {
          key = "gb";
          desc = "Git blame";
          command = "log --patch --max-count=100 -- %";
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
        {
          mode = "v";
          key = "gr";
          action = ":w !git apply --whitespace=nowarn --recount -R<CR>";
          options = {
            silent = true;
            desc = "Git Revert selected hunk";
          };
        }
        {
          mode = "v";
          key = "ga";
          action = ":w !git apply --whitespace=nowarn --recount<CR>";
          options = {
            silent = true;
            desc = "Git Apply selected hunk";
          };
        }
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
          command = "commit --verbose";
        })
        (gitChained {
          key = "<Leader>ca";
          desc = "Git add all";
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

        # Clipboard
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

        # Sessions
        (lua {
          key = "<Leader>ps";
          desc = "Save session";
          code = "MiniSessions.write('.nvim.session'); vim.notify('Session saved')";
        })
        (lua {
          key = "<Leader>pd";
          desc = "Delete session";
          code = "MiniSessions.delete('.nvim.session'); vim.notify('Session deleted')";
        })
        (lua {
          key = "<Leader>n";
          desc = "List notifications";
          code = "MiniNotify.show_history()";
        })

        # Window resizing
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
      ];

    };
  };
}
