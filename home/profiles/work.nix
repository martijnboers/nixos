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
in {
  options.maatwerk.work = {
    enable = mkEnableOption "Enable packages and configuration specific to work";
  };

  config = mkIf cfg.enable {
    maatwerk.vscode.enable = true;
    home.packages = with pkgs; [
      stable.jetbrains.pycharm-community # https://hydra.nixos.org/build/282372975
      stable.jetbrains.webstorm
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      httpie-desktop
      distrobox # run any linux distro

      teams.desktop
      teams.script
      claud.desktop
      claud.script
      hetzner.desktop
      hetzner.script
      (citrix_workspace.override {version = "24.8.0.98";})
    ];
  };
}
