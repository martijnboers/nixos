{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";

  imports = [
    # All system install packages
    ./packages.nix

    # Custom modules
    ./modules/ranger.nix

    # Or modules exported from other flakes (such as nix-colors):
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # Here are config values for installed programs
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

      # Sadly home.sessionVariables not working..
      export VISUAL=nvim
      export EDITOR=nvim
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck" "direnv" "fzf" "z"];
    };
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
      "alt+j" = "next_tab";
      "alt+k" = "previous_tab";
      "alt+shift+j" = "move_tab_forward";
      "alt+shift+k" = "move_tab_backward";
      "alt+w" = "close_tab";
      "alt+shift+r" = "set_tab_title";
    };
    theme = "Doom One";
  };

  programs.ranger = {
    enable = true;
    enableFishIntegration = true;
    extraConfig = ''
      map e shell vim %c
      set vcs_aware true
      set draw_borders separators
      set nested_ranger_warning error
      set preview_images true
      set preview_images_method kitty
    '';
  };

  # KDE
  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorscheme = "BreezeDark";
    };
  };

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
