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

  imports = [
    ./keymaps.nix
    ./plugins.nix
    ./dap.nix
  ];

  config = mkIf cfg.enable {
    programs.nixvim = {
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

      clipboard = {
        providers.wl-copy.enable = true;
      };
    };
  };
}
