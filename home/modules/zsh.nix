{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.maatwerk.zsh;
in {
  options.maatwerk.zsh = {
    enable = mkEnableOption "Full zsh config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [nh nom];

    programs.zsh = {
      enable = true;
      shellAliases = let
        deploy-custom =
          pkgs.writeShellScriptBin "deploy-custom"
          ''
            set -euo pipefail
            cd /home/martijn/Nix
            git submodule foreach git pull --depth=1
            nix flake lock --update-input secrets
            if [ $# -eq 0 ]; then
                nh os switch \
                  ".?submodules=1" \
                  --ask \
                  -- \
                  --fallback
            else
                TARGET="$1"
                nixos-rebuild switch \
                  --use-remote-sudo \
                  --fallback \
                  --verbose \
                  --flake ".?submodules=1#''${1}" \
                  --target-host "martijn@''${1}.machine.thuis"
            fi
          '';
      in {
        # --- NixOS specific --------
        deploy = lib.getExe deploy-custom; # $ deploy {?host}
        mdeploy = "darwin-rebuild switch --flake '/Users/martijn/nixos/.?submodules=1#paddy'";
        update = "nix flake update";
        # ---------------------------
        dud = "docker compose up -d";
        fixup = "ga . && gc --amend --no-edit";
        xev = "wev"; # wayland xev
        vim = "nvim";
        rm = "trash-put"; # use trash for cli
        ls = "lsd"; # fancy ls
        kssh = "kitty +kitten ssh";
        pow = "ssh hadouken.machine.thuis";
        wolk = "ssh shoryuken.machine.thuis";
        pi = "ssh tenshin.machine.thuis";
        socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
        proxy = "doas tailscale set --exit-node shoryuken";
        proxyd = "doas tailscale set --exit-node=";
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
        plugins = ["git" "thefuck" "direnv" "fzf" "z" "ssh-agent"];
      };
    };
  };
}
