{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    shellAliases = let
      defaultNixFlags = "--flake /home/martijn/Nix";
    in {
      # --- NixOS specific --------
      deploy = "doas nixos-rebuild switch ${defaultNixFlags}";
      debug = "doas nixos-rebuild switch ${defaultNixFlags} --show-trace --verbose";
      testbuild_hadouken = "nixos-rebuild build --option sandbox false ${defaultNixFlags}#hadouken";
      testbuild_glassdoor = "nixos-rebuild build ${defaultNixFlags}#glassdoor";
      update = "nix flake update";
      # ---------------------------
      dud = "docker compose up -d";
      fixup = "ga . && gc --amend --no-edit";
      xev = "wev"; # wayland xev
      vim = "nvim";
      rm = "trash-put"; # use trash for cli
      ls = "lsd"; # fancy ls
      ssh = "kitty +kitten ssh";
      pow = "ssh ssh.thuis.plebian.nl";
      socks = "ssh -D 1337 -q -C -N ssh.thuis.plebian.nl";
      readme = "cat README* | glow";
      keeb-c = "qmk compile -kb peej/lumberjack -km martijnboers";
      keeb-f = "qmk flash -kb peej/lumberjack -km martijnboers";
      question = "mods -f \"$1\"";
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
