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
          notes = "(cd ~/Notes && nvim)";
          keyboard-compile = "qmk compile -kb peej/lumberjack -km martijn";
          keyboard-flash = "qmk flash -kb peej/lumberjack -km martijn";
          croc = "croc --relay dosukoi.machine.thuis:9009 --relay6 fd7a:115c:a1e0::9";
          extreme-pro = ''sudo veracrypt -t "/dev/disk/by-partlabel/Extreme\\x20Pro" /mnt/veracrypt1/'';

          proxy = "nym-vpnc connect";
          proxyoff = "nym-vpnc disconnect";
          socks = "nym-vpnc socks5 enable --socks5-address 127.0.0.1:1080 --exit-random";
          nvmix = "nym-vpnc tunnel set --two-hop off";
          nvfast = "nym-vpnc tunnel set --two-hop on";

          # git alias
          ga = "git add";
          gc = "git commit --verbose";
          gco = "git checkout";
          gbd = "git branch --delete";
          gcb = "git checkout -b";
          gf = "git fetch";
          gl = "git pull";
          gs = "git status";
          glg = "git log --stat";
          gp = "git push";
          gpf = "git push --force-with-lease";
          grb = "git rebase";
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
      antidote = {
        enable = true;
        plugins = [
          "jeffreytse/zsh-vi-mode"
          "ohmyzsh/ohmyzsh path:plugins/ssh-agent"
          "mafredri/zsh-async"
          "sindresorhus/pure"
        ];
      };
      completionInit = "";
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
          pureConfig = lib.mkOrder 800 ''
            PURE_GIT_PULL=0

            zstyle ":prompt:pure:git:branch" color "242"
            zstyle ":prompt:pure:git:dirty" color "218"
            zstyle ":prompt:pure:git:action" color "242"
            zstyle ":prompt:pure:prompt:success" color "140"
            zstyle ":prompt:pure:prompt:error" color "red"
            zstyle ":prompt:pure:execution_time" color "yellow"
          '';
          last =
            lib.mkOrder 1500 # bash
              ''
                export $(cat ${config.age.secrets.llm.path} | xargs)

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
          pureConfig
          general
          last
        ];
      dotDir = "${config.xdg.configHome}/zsh";
      zprof.enable = false;
      syntaxHighlighting.enable = true;
      history = {
        # Point the history file to the void
        path = "/dev/null";
        # Stop Zsh from saving history to disk
        save = 0;
        # Even though we aren't saving to disk, Zsh needs an in-memory
        # buffer (size) so Atuin's hooks can capture the command
        size = 10000;
        # Since we aren't using a file, we can't share via file.
        share = false;
      };
    };

    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      daemon.enable = true;

      settings = {
        # zsh isn't saving history
        sync_shell_history = false;
        ctrl_n_shortcuts = true;
        show_preview = false;
        show_help = false;
        show_tabs = false;
        ui.columns = [
          "command"
          "host"
        ];
        auto_sync = true;
        show_someting = false;
        sync_address = "https://atuin.thuis";
        sync_frequency = "10m";
        filter_mode_shell_up_key_binding = "session";
        update_check = false;
        enter_accept = true;
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
