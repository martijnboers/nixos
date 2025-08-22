{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.browser;
  mkChromeWrapper = name: url: rec {
    script = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.ungoogled-chromium ];
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
  hetzner = mkChromeWrapper "hetzner" "https://console.hetzner.cloud";
  kvm = mkChromeWrapper "kvm" "https://10.10.0.11/kvm/#";
in
{
  options.maatwerk.browser = {
    enable = mkEnableOption "Add browsers + config";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      stable.ungoogled-chromium

      teams.desktop
      teams.script
      hetzner.desktop
      hetzner.script
      kvm.desktop
      kvm.script
    ];
    programs.librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "identity.fxaccounts.enabled" = true;
        "identity.sync.tokenserver.uri" = "https://sync.thuis/1.0/sync/1.5";
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0;
        "network.trr.mode" = 2; # fallback to system
        "network.trr.uri" = "https://dns.thuis/dns-query";

        # https://bugzilla.mozilla.org/show_bug.cgi?id=1732114
        "privacy.resistFingerprinting" = false;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
      };
    };
  };
}
