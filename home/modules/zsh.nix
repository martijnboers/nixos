{
  pkgs,
  config,
  inputs,
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
    home.packages = [ inputs.nh.packages.${pkgs.system}.default ];

    programs.zsh = {
      enable = true;
      shellAliases =
        let
          deploy-custom = pkgs.writeShellScriptBin "deploy-custom" ''
            set -euo pipefail
            cd /home/martijn/Nix
            git submodule update --remote secrets
            nix flake update secrets

            target_args=()

            if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
              hostname="$1"
              target_args+=(--hostname "$hostname" --target-host "martijn@''${hostname}.machine.thuis")
              shift
            fi
            export NH_FLAKE=/home/martijn/Nix
            nh os switch --ask "''${target_args[@]}" --fallback "$@"
          '';
          sshAlias = name: "kitty +kitten ssh ${name}.machine.thuis";
        in
        {
          # --- NixOS specific --------
          deploy = lib.getExe deploy-custom; # $ deploy {?host} --verbose
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
          notes = "nvim /mnt/notes/";
          readme = "cat README* | glow";
          keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
          keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";
          proxy = "sudo systemctl start wg-quick-wg0";
          proxyd = "sudo systemctl stop wg-quick-wg0";

          pow = sshAlias "hadouken";
          wolk = sshAlias "shoryuken";
          pi = sshAlias "tenshin";
          zima = sshAlias "tatsumaki";
          desktop = sshAlias "nurma";
          nofail = sshAlias "rekkaken";

          socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
          extreme-pro = ''sudo veracrypt -t "/dev/disk/by-partlabel/Extreme\\x20Pro" /mnt/veracrypt1/'';

          # llm
          "c\?" = "mods -f -m cli-fast --role cli \"$1\"";
          "f\?" = "mods -f --role forensics \"$1\"";
          "s\?" = "mods -f --role sys \"$1\"";
          "h\?" = "OLLAMA_HOST=https://ollama.thuis ollama run wizardlm2";
        };
      dotDir = "/home/martijn/.config/zsh";
      initContent = ''
        # Powerlevel10k Zsh theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

        # AI keys
        export $(cat ${config.age.secrets.llm.path} | xargs)
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
