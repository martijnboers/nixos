{...}: {
  # Neovim
  programs.nixvim = {
    enable = true;

    clipboard = {
      providers.wl-copy.enable = true;
    };

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
    };
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
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

      cmp = {
        enable = true;
        settings = {
        snippet.expand = "luasnip";
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<Down>" = "cmp.mapping.select_next_item()";
          "<Up>" = "cmp.mapping.select_prev_item()";
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
        };
        sources = [
          {name = "nvim_lsp";}
          {name = "path";} # what are these values?
          {name = "buffer";}
          {name = "orgmode";}
          {name = "neorg";}
        ];
        };
      }; # auto-complete intelij like


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
          gopls.enable = true;
        };
      };
    };
  };
}
