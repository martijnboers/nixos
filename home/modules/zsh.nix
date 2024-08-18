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
      pow = "ssh hadouken.machine.thuis";
      wolk = "ssh shoryuken.machine.thuis";
      socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
      proxy = "doas tailscale set --exit-node shoryuken --login-server=https://headscale.cloud.plebian.nl";
      proxyd = "doas tailscale set --exit-node= --login-server=https://headscale.cloud.plebian.nl";
      readme = "cat README* | glow";
      keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
      keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";
      question = "mods -f \"$1\"";
      fluister = "OLLAMA_HOST=https://ollama.thuis ollama run wizardlm2";
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
