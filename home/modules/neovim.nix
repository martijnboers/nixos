{...}: {
  # Neovim
  programs.nixvim = {
    enable = true;

    clipboard = {
      providers.wl-copy.enable = true;
    };

    options = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
    };
    colorschemes.catppuccin = {
      enable = true;
      flavour = "mocha";
    };
    plugins = {
      lightline.enable = true; # bar at the bottom
      gitgutter.enable = true; # show changed files in git
      lastplace.enable = true; # re-open files where left off
      which-key.enable = true; # popup with possible key combinations
      barbecue.enable = true; # breadcrumbs at top of code files
      nvim-tree.enable = true; # left pane with files

      treesitter = {
        enable = true;
        indent = true;
        nixGrammars = true;
      }; # fancy syntax highlighting

      telescope = {
        enable = true;
        keymaps = {
          "<C-e>" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      }; # fzf fuzzy finding

      nvim-cmp = {
        enable = true;
        snippet.expand = "luasnip";
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<Down>" = {
            modes = ["i" "s"];
            action = "cmp.mapping.select_next_item()";
          };
          "<Up>" = {
            modes = ["i" "s"];
            action = "cmp.mapping.select_prev_item()";
          };
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
        };
        sources = [
          {name = "nvim_lsp";}
          {name = "path";} # what are these values?
          {name = "buffer";}
          {name = "orgmode";}
          {name = "neorg";}
        ];
      }; # auto-complete

      # gitblame.enable = true;
      # barbar.enable = true; # clibable tabs

      lsp-format = {
        enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          nil_ls.enable = true;
          html.enable = true;
          jsonls.enable = true;
          terraformls.enable = true;
          pyright.enable = true;
        };
      };
    };
  };
}
