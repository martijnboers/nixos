{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.zsh;
in
{
  options.maatwerk.zsh = {
    enable = mkEnableOption "Full zsh config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nh
      nom
    ];

    programs.zsh = {
      enable = true;
      shellAliases =
        let
          deploy-custom = pkgs.writeShellScriptBin "deploy-custom" ''
            set -euo pipefail
            cd /home/martijn/Nix/secrets
            git pull
            cd ../
            git submodule foreach git pull --depth=1
            nix flake update secrets
            if [ $# -eq 0 ]; then
              nh os switch \
                ".?submodules=1" \
                --ask \
                -- \
                --fallback
            else
              nixos-rebuild switch \
                --use-remote-sudo \
                --fallback \
                --verbose \
                --flake ".?submodules=1#''${1}" \
                --target-host "martijn@''${1}.machine.thuis"
            fi
          '';
          sshAlias = name: "kitty +kitten ssh ${name}.machine.thuis";
        in
        {
          # --- NixOS specific --------
          deploy = lib.getExe deploy-custom; # $ deploy {?host}
          mdeploy = "sudo darwin-rebuild switch --flake '/Users/martijn/nixos/.?submodules=1#paddy'";
          update = "nix flake update";
          # ---------------------------
          dud = "docker compose up -d";
          fixup = "ga . && gc --amend --no-edit";
          xev = "wev"; # wayland xev
          vim = "nvim";
          ls = "lsd"; # fancy ls
          fmt = "nix fmt ~/Nix/*.nix";
          adel = "read -r s&&atuin search '$s' --delete";
          readme = "cat README* | glow";
          keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
          keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";

          pow = sshAlias "hadouken";
          wolk = sshAlias "shoryuken";
          pi = sshAlias "tenshin";
          zima = sshAlias "tatsumaki";
          giga = sshAlias "nurma";
          socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
          proxy = "sudo tailscale set --exit-node shoryuken";
          proxyd = "sudo tailscale set --exit-node=";

          # llm
          "c\?" = "mods -f -m cli-fast --role cli \"$1\"";
          "f\?" = "mods -f --role forensics \"$1\"";
          "s\?" = "mods -f --role sys \"$1\"";
          "h\?" = "OLLAMA_HOST=https://ollama.thuis ollama run wizardlm2";
        };
      dotDir = ".config/zsh";
      initContent = ''
        # Powerlevel10k Zsh theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

        # AI keys
        source ${config.age.secrets.llm.path}
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "direnv"
          "fzf"
          "z"
          "ssh-agent"
          "vi-mode"
        ];
      };
    };
  };
}
