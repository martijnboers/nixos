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
      dezoomify-rs # art archival
    ];

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
          # --- NixOS specific ---
          deploy = lib.getExe deploy-custom; # $ deploy {?host} --verbose
          update = "nix flake update";

          wut = "journalctl -b -1 -e"; # previous boot crash
          xev = "wev"; # wayland xev
          adel = "read -r s&&atuin search '$s' --delete";
          notes = "(cd /mnt/notes && nvim)";
          readme = "cat README* | ${lib.getExe pkgs.glow}";
          keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
          keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";
          socks = "ssh -D 1337 -q -C -N hadouken.machine.thuis";
          croc = "croc --relay dosukoi.machine.thuis:9009 --relay6 fd7a:115c:a1e0::9";
          extreme-pro = ''sudo veracrypt -t "/dev/disk/by-partlabel/Extreme\\x20Pro" /mnt/veracrypt1/'';
          "c\?" = "mods -f -m google-cli --role cli \"$1\" --quiet";
          "f\?" = "mods -f -m google-pro --role forensics \"$1\" --quiet";
          "s\?" = "mods -f -m google-pro --role sys \"$1\" --quiet";

          # git alias
          ga = "git add";
          gc = "git commit --verbose";
          gco = "git checkout";
          gbd = "git branch --delete";
          gcb = "git checkout -b";
          gf = "git fetch";
          gl = "git pull";
          glg = "git log --stat";
          gp = "git push";
          gpf = "git push --force-with-lease --force-if-includes";
          grb = "git rebase";
          groh = "git reset origin/$(git_current_branch) --hard";
          gwip = ''git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'';
          fixup = "ga . && gc --amend --no-edit";

          # ssh nicknames
          pow = sshAlias "hadouken";
          wolk = sshAlias "shoryuken";
          pi = sshAlias "tenshin";
          zima = sshAlias "tatsumaki";
          desktop = sshAlias "nurma";
          nofail = sshAlias "rekkaken";
          router = sshAlias "dosukoi";
          ap = sshAlias "suzaku";
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
                fixkey() {
                  # Find all USB devices with Vendor ID 1050 (Yubico)
                  for id in $(grep -l "1050" /sys/bus/usb/devices/*/idVendor); do
                    dev=$(basename $(dirname "$id"))
                    echo "Resetting YubiKey on USB port $dev..."
                    echo "$dev" | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null
                    sleep 0.5
                    echo "$dev" | sudo tee /sys/bus/usb/drivers/usb/bind > /dev/null
                    echo "Done."
                  done
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
            name = "jeffreytse/zsh-vi-mode";
            tags = [ "from:github" ];
          }
          {
            name = "plugins/ssh-agent";
            tags = [ "from:oh-my-zsh" ];
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

    programs = {
      zoxide = {
        enable = true; # Use z to goto visited paths
        enableZshIntegration = true;
      };
      nh = {
        enable = true; # nixos-rebuild wrapper
        flake = "${config.home.homeDirectory}/Nix";
      };
      fzf = {
        enable = true; # A command-line fuzzy finder
        enableZshIntegration = true;
      };
      direnv = {
        enable = true; # Execute commands when stepping into directory
        enableZshIntegration = true;
      };
      lsd = {
        enable = true; # fancy ls
        enableZshIntegration = true;
      };
    };
  };
}
