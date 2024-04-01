{
  pkgs,
  config,
  ...
}: {
  # ZSH stuff
  programs.zsh = {
    enable = true;
    shellAliases = let
      defaultNixFlags = "--impure --use-remote-sudo --flake /home/martijn/Nix";
    in {
      # --- NixOS specific --------
      deploy = "nixos-rebuild switch ${defaultNixFlags}";
      debug = "nixos-rebuild switch ${defaultNixFlags} --show-trace --verbose";
      testbuild = "nixos-rebuild build --option sandbox false ${defaultNixFlags}#hadouken";
      update = "nix flake update";
      # ---------------------------
      dud = "docker compose up -d";
      fixup = "ga . && gc --amend --no-edit";
      xev = "wev"; # wayland xev
      vim = "nvim";
      rm = "trash-put"; # use trash for cli
      ls = "lsd"; # fancy ls
      ssh = "kitty +kitten ssh";
      pow = "ssh ssh.thuis.plebian.nl -p 666";
      socks = "ssh -D 1337 -q -C -N ssh.thuis.plebian.nl -p 666";
      readme = "cat README* | glow";
      question = "() { mods -f \"$1\" | glow; }";
    };
    dotDir = ".config/zsh";
    initExtra = ''
      # Powerlevel10k Zsh theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

      # Open AI key
      source ${config.age.secrets.openai.path}
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck" "direnv" "fzf" "z" "fd" "ssh-agent"];
    };
  };
}
