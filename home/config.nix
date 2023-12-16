{
  inputs,
  lib,
  pkgs,
  ...
}: {
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "23.11";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  imports = [
    # All user level packages
    ./packages.nix

    # Custom modules
    ./modules/ranger.nix

    inputs.plasma-manager.homeManagerModules.plasma-manager
    inputs.nixvim.homeManagerModules.nixvim
  ];

  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "sudo nixos-rebuild switch --flake /home/martijn/Nix#glassdoor";
      dud = "docker-compose up -d";
      fixup = "ga . && gc --amend --no-edit";
      xev = "wev"; # wayland xev
      vim = "nvim";
    };
    dotDir = ".config/zsh";
    initExtra = ''
      # Powerlevel10k Zsh theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck" "direnv" "fzf" "z"];
    };
  };

  # Neovim
  programs.nixvim = {
    enable = true;
    options = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2;        # Tab width should be 2
    };
    colorschemes.catppuccin = {
        enable = true;
        flavour = "mocha";
    };
    plugins.lightline.enable = true;
  };

  # KDE
  programs.plasma = {
    enable = true;

    spectacle.shortcuts = {
      captureRectangularRegion = "Print";
    };

    configFile = {
      spectaclerc.General = {
        autoSaveImage = false;
      };
      kdeglobals = {
        Icons.Theme = "Nordic-darker";
      };
    };

    workspace.clickItemTo = "select";
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Jetbrains Mono";
      font_size = "12.0";
      scrollback_lines = 10000;
      window_padding_width = 6;

      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Display
      sync_to_monitor = true;
      enable_audio_bell = false;
    };
    keybindings = {
      "ctrl+pgdn" = "next_tab";
      "ctrl+pgup" = "previous_tab";
      "ctrl+shift+pgdn" = "move_tab_forward";
      "ctrl+shift+pgup" = "move_tab_backward";
      "ctrl+w" = "close_tab";
      "alt+j" = "previous_window";
      "alt+k" = "next_window";
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
    };
    theme = "Gruvbox Material Dark Medium";
  };

  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@plebian.nl";
    signing = {
      key = "FDC7B670BF26B101";
      signByDefault = true;
    };
    extraConfig = {
      pull.rebase = "true";
    };
  };

  programs.ranger = {
    enable = true;
    extraConfig = ''
      map e shell vim %c
      set vcs_aware true
      set draw_borders separators
      set nested_ranger_warning error
      set preview_images true
      set preview_images_method kitty
    '';
  };
}
