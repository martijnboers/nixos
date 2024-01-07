{pkgs, ...}: {
  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = let
      defaultNixFlags = "--impure --use-remote-sudo --flake /home/martijn/Nix";
    in {
      # --- NixOS specific --------
      deploy = "nixos-rebuild switch ${defaultNixFlags}";
      debug = "nixos-rebuild switch ${defaultNixFlags} --show-trace --verbose";
      testbuild = "nixos-rebuild build ${defaultNixFlags}#hadouken";
      update = "nix flake update";
      # ---------------------------
      dud = "docker compose up -d";
      fixup = "ga . && gc --amend --no-edit";
      xev = "wev"; # wayland xev
      vim = "nvim";
      rm = "trash-put"; # use trash for cli
      ks = "kitty +kitten ssh";
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
}
