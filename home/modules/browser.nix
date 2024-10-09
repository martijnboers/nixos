{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.thuis.browser;
in {
  options.thuis.browser = {
    enable = mkEnableOption "Add browsers + config";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ungoogled-chromium
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
