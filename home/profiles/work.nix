{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.maatwerk.work;
  mkChromeWrapper = name: url: rec {
    script = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [pkgs.ungoogled-chromium];
      text = ''
        chromium --new-tab "${url}"
      '';
    };
    desktop = pkgs.makeDesktopItem {
      name = name;
      exec = getExe script;
      desktopName = "${name} chrome";
      startupWMClass = name;
      terminal = true;
    };
  };
  teams = mkChromeWrapper "teams" "https://teams.microsoft.com";
  claud = mkChromeWrapper "claud" "https://claud.ai";
  hetzner = mkChromeWrapper "hetzner" "https://console.hetzner.cloud";
  kvm = mkChromeWrapper "kvm" "https://10.10.0.11/kvm/#";
in {
  options.maatwerk.work = {
    enable = mkEnableOption "Enable packages and configuration specific to work";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      stable.jetbrains.pycharm-community # https://hydra.nixos.org/build/282372975
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      httpie-desktop
      wireshark

      teams.desktop
      teams.script
      claud.desktop
      claud.script
      hetzner.desktop
      hetzner.script
      kvm.desktop
      kvm.script
      citrix_workspace
    ];
  };
}
