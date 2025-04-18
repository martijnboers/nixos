{...}: {
  programs.nixvim = {
    enable = true;

    clipboard = {
      providers.wl-copy.enable = true;
    };

    extraConfigVim = ''
      filetype indent on
      set autoread
    '';

    keymaps = [
      {
        action = "<cmd>Neotree toggle<cr>";
        key = "<C-b>";
      }
      {
        action = "<cmd>bprevious<cr>";
        key = "<C-j>";
      }
      {
        action = "<cmd>bnext<cr>";
        key = "<C-k>";
      }
      {
        action = "<cmd>bd<cr>";
        key = "x";
      }
    ];

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
      lastplace.enable = true; # re-open files where left off
      which-key.enable = true; # popup with possible key combinations
      barbecue.enable = true; # breadcrumbs at top of code files
      neo-tree.enable = true; # left pane with files
      web-devicons.enable = true; # needed for another plugin
      barbar.enable = true; # tabs like any other editor
      comment.enable = true;

      gitsigns = {
        enable = true; 
        autoLoad = true;
      }; # diff + gutter signs

      treesitter = {
        enable = true;
        settings = {
	  indent.enable = true;
	};
        nixGrammars = true;
      }; # Syntax highlighting 

      telescope = {
        enable = true;
        keymaps = {
          "<C-e>" = "find_files";
          "<C-f>" = "live_grep";
          "<C-t>" = "lsp_document_symbols";
          "<C-g>" = "buffers";
          "<leader>fh" = "help_tags";
        };
        settings = {
          pickers = {
            lsp_document_symbols = {
              theme = "ivy";
            };
          };
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
            {name = "path";}
            {name = "buffer";}
            {name = "orgmode";}
            {name = "neorg";}
          ];
        };
      }; # auto-complete intelij like additionally supplied by lsp

      lsp-format = {
        enable = true;
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
