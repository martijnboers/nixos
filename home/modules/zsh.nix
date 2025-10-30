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
      nh # nixos-rebuild wrapper
      direnv # Execute commands when stepping into directory
      fzf # A command-line fuzzy finder
      zoxide # use z to goto visited paths
      lsd # fancy ls
      glow # fancy markdown
    ];

    programs.zsh = {
      enable = true;
      shellAliases =
        let
          deploy-custom = pkgs.writeShellScriptBin "deploy-custom" ''
            set -euo pipefail
            export NH_FLAKE=${config.home.homeDirectory}/Nix

            cd $NH_FLAKE
            git submodule update --remote secrets
            nix flake update secrets

            target_args=()

            if [[ $# -gt 0 ]]; then
              hostname="$1"
              target_args+=(--hostname "$hostname" --target-host "martijn@''${hostname}.machine.thuis")
              shift
            fi
            nh os switch --ask "''${target_args[@]}" 
          '';
          sshAlias = name: "ssh ${name}.machine.thuis";
        in
        {
          # --- NixOS specific --------
          deploy = lib.getExe deploy-custom; # $ deploy {?host} --verbose
          update = "nix flake update";
          # ---------------------------
          fixup = "ga . && gc --amend --no-edit";
          xev = "wev"; # wayland xev
          ls = "lsd"; # fancy ls
          adel = "read -r s&&atuin search '$s' --delete";
          notes = "(cd /mnt/notes && nvim)";
          readme = "cat README* | glow";
          keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
          keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";

          pow = sshAlias "hadouken";
          wolk = sshAlias "shoryuken";
          pi = sshAlias "tenshin";
          zima = sshAlias "tatsumaki";
          desktop = sshAlias "nurma";
          nofail = sshAlias "rekkaken";
          router = sshAlias "dosukoi";

          socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
          extreme-pro = ''sudo veracrypt -t "/dev/disk/by-partlabel/Extreme\\x20Pro" /mnt/veracrypt1/'';

          "c\?" = "mods -f -m cli-fast --role cli \"$1\"";
        };
      completionInit = ""; # let zplug do this
      initContent = # bash
        ''
          s() {
            nix shell "nixpkgs#$1"
          }
          wp() {
            rm -f wp.jpg
            dezoomify-rs --compression 0 --largest $1 wp.jpg
          }
          export $(cat ${config.age.secrets.llm.path} | xargs)
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh
        '';
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      zprof.enable = false;
      zplug = {
        enable = true;
        plugins = [
          {
            name = "plugins/ssh-agent";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/direnv";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/git";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/z";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "jeffreytse/zsh-vi-mode";
            tags = [ "from:github" ];
          }
          {
            name = "zsh-users/zsh-syntax-highlighting";
            tags = [ "from:github" ];
          }
        ];
      };
    };
  };
}
