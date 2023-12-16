{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.stateVersion = "23.11";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "martijn";
  home.homeDirectory = "/home/martijn";

  imports = [
    # All user level packages
    ./packages.nix

    # Custom modules
    ./modules/ranger.nix

    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "sudo nixos-rebuild switch --flake /home/martijn/Nix#glassdoor";
      dud = "docker-compose up -d";
      fixup = "ga . && gc --amend --no-edit";
      xev = "wev"; # wayland xev
    };
    dotDir = ".config/zsh";
    localVariables = {
      VISUAL = "nvim";
      EDITOR = "nvim";
    };
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      LazyVim # TODO: make work
    ];
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
      font_family = "mononoki Nerd Font Mono";
      font_size = "12.0";
      # Window
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
    };
    theme = "Material Dark";
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
