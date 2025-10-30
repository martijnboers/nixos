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
    programs.zsh = {
      enable = true;
      shellAliases =
        let
          deploy-custom = pkgs.writeShellScriptBin "deploy-custom" ''
            set -euo pipefail
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
          adel = "read -r s&&atuin search '$s' --delete";
          notes = "(cd /mnt/notes && nvim)";
          readme = "cat README* | ${lib.getExe pkgs.glow}";
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
      initContent =
        let
          general =
            lib.mkOrder 1000 # bash
              ''
                s() {
                  nix shell "nixpkgs#$1"
                }
                wp() {
                  rm -f wp.jpg
                  dezoomify-rs --compression 0 --largest $1 wp.jpg
                }
              '';
          last =
            lib.mkOrder 1500 # bash
              ''
                export $(cat ${config.age.secrets.llm.path} | xargs)
                source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
                test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

                function _force_atuin_binding_once() {
                  # Forcefully bind CTRL+R in the vi keymaps to atuin
                  bindkey -M viins '^R' atuin-search
                  bindkey -M vicmd '^R' atuin-search
                  precmd_functions=(''${(pz)precmd_functions:#_force_atuin_binding_once})
                }
                precmd_functions+=(_force_atuin_binding_once)
              '';
        in
        lib.mkMerge [
          general
          last
        ];
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      zprof.enable = false;
      syntaxHighlighting.enable = true;
      zplug = {
        enable = true;
        plugins = [
          {
            name = "plugins/ssh-agent";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/git";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "jeffreytse/zsh-vi-mode";
            tags = [ "from:github" ];
          }
        ];
      };
    };

    programs.atuin = {
      enable = true; # Command history database
      flags = [ "--disable-up-arrow" ];
      enableZshIntegration = true;
      daemon.enable = true;

      settings = {
        auto_sync = true;
        sync_address = "https://atuin.thuis";
        sync_frequency = "10m";
        update_check = false;
        style = "compact";
        sync.records = true;
      };
    };

    programs.zoxide = {
      enable = true; # Use z to goto visited paths
      enableZshIntegration = true;
    };

    programs.nh = {
      enable = true; # nixos-rebuild wrapper
      flake = "${config.home.homeDirectory}/Nix";
    };

    programs.fzf = {
      enable = true; # A command-line fuzzy finder
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true; # Execute commands when stepping into directory
      enableZshIntegration = true;
    };

    programs.lsd = {
      enable = true; # fancy ls
      enableZshIntegration = true;
    };

  };
}
