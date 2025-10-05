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
      policies =
        let
          mkExtension =
            {
              id,
              name,
              pinned ? false,
            }:
            {
              "${id}" = {
                default_area = if pinned then "navbar" else "menubar";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
            };
          # Get ID https://github.com/mkaply/queryamoid/releases/tag/v0.1
          extensionSettings = lib.mergeAttrsList (
            map mkExtension [
              {
                id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
                name = "bitwarden-password-manager";
                pinned = true;
              }
              {
                id = "uBlock0@raymondhill.net";
                name = "ublock-origin";
                pinned = true;
              }
              {
                id = "{c6e8bd66-ebb4-4b63-bd29-5ef59c795903}";
                name = "shiori_ext";
                pinned = true;
              }
	      {
		id = "7esoorv3@alefvanoon.anonaddy.me";
		name = "libredirect";
	      }
              {
                id = "@testpilot-containers";
                name = "multi-account-containers";
              }
              {
                id = "transmitter@unrelenting.technology";
                name = "transmitter-for-transmission";
              }
              {
                id = "{44ec79ad-72a9-471d-962d-49e7e5501d97}";
                name = "earth-view-from-google";
              }
              {
                id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
                name = "vimium-ff";
              }
              {
                id = "deArrow@ajay.app";
                name = "dearrow";
              }
              {
                id = "sponsorBlocker@ajay.app";
                name = "sponsorblock";
              }
            ]
          );
        in
        {
          ExtensionSettings = extensionSettings;
          PasswordManagerEnabld = false;
          NoDefaultBookmarks = true;
          SkipTermsOfUse = true;
          Containers = {
            Default = [
              {
                name = "Work";
                icon = "briefcase";
                color = "yellow";
              }
            ];
          };
        };
      profiles = {
        default = {
          isDefault = true;
          settings = {
            "webgl.disabled" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown.sessions" = false;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
            "browser.fixup.domainsuffixwhitelist.thuis" = true;
            "network.cookie.lifetimePolicy" = 0;
            "network.trr.mode" = 2; # fallback to system
            "network.trr.uri" = "https://dns.thuis/dns-query";
            "signon.rememberSignons" = false; # builtin password manager
            "extensions.autoDisableScopes" = 0; # auto-enable installed plugins
            "full-screen-api.transition-duration.enter" = "0 0";
            "full-screen-api.transition-duration.leave" = "0 0";
            "accessibility.force_disabled" = true;
            "browser.uidensity" = 1; # compact
            "browser.backspace_action" = 0; # enable backspace back history
            "sidebar.verticalTabs" = true; # we zen browser now
            "sidebar.visibility" = "expand-on-hover";
            "sidebar.animation.expand-on-hover.duration-ms" = "100";
            "sidebar.revamp.round-content-area" = true;

            # https://bugzilla.mozilla.org/show_bug.cgi?id=1732114
            "privacy.resistFingerprinting" = false;
            "privacy.fingerprintingProtection" = true;
            "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
          };
          extensions.force = true;
          search = {
            force = true;
            default = "ddg";
            engines =
              let
                mkEngine =
                  { id, url }:
                  {
                    "${id}" = {
                      urls = [
                        { template = url; }
                      ];
                      definedAliases = [ "!${id}" ];
                    };
                  };
              in
              {
                google.metaData.alias = "!g";
                wikipedia.metaData.alias = "!w";
              }
              // (lib.attrsets.mergeAttrsList (
                map mkEngine [
                  {
                    id = "pkgs";
                    url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
                  }
                  {
                    id = "nixos";
                    url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
                  }
                  {
                    id = "hm";
                    url = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
                  }
                  {
                    id = "cs";
                    url = "https://github.com/search?type=code&q={searchTerms}";
                  }
                  {
                    id = "gh";
                    url = "https://github.com/search?q={searchTerms}";
                  }
                  {
                    id = "k";
                    url = "https://kagi.com/search?q={searchTerms}";
                  }
                ]
              ));
          };
        };
      };
    };
  };
}
