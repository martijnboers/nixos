{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.crowdsec;

  isLogForwarder = cfg.agent && cfg.acquisitions != [ ];
  lapiPort = 49837;
  lapiFqdn = "rekkaken.machine.thuis";
  lapiUri = "http://${lapiFqdn}:${toString lapiPort}";

in
{
  options.hosts.crowdsec = {
    enable = mkEnableOption "Crowdsec services on this host";
    agent = mkOption {
      type = types.bool;
      default = true;
      description = "True for an agent, False for the central LAPI.";
    };
    acquisitions = mkOption {
      type = with types; listOf (pkgs.formats.yaml { }).type;
      default = [ ];
      description = "List of log sources. On an agent, defining this enables log-forwarding.";
    };
    enrollKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "(LAPI only) Path to the decrypted secret file for the LAPI's enrollment key.";
    };
    machinePasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "(Log-Forwarding Agent only) Path to the decrypted secret file for this machine's LAPI password.";
    };
    bouncerApiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        (LAPI only) Path to the DECRYPTED secret file for the bouncer's API key.
        This file must be formatted as 'BOUNCER_API_KEY=...'.
        This option is not used for agents.
      '';
    };
  };

  config = mkIf cfg.enable {
    # --- Assertions for correct configuration ---
    assertions = [
      {
        assertion = !cfg.agent -> cfg.bouncerApiKeyFile != null;
        message = "hosts.crowdsec.bouncerApiKeyFile must be set when configured as a LAPI (agent = false).";
      }
      {
        assertion = cfg.agent -> cfg.bouncerApiKeyFile == null;
        message = "hosts.crowdsec.bouncerApiKeyFile should not be set for agents (agent = true). Agents use a hardcoded secret source.";
      }
    ];

    # --- Internal Secret Definition for Agents ONLY ---
    # The source .age file must be formatted as 'BOUNCER_API_KEY=...'
    age.secrets."shared-bouncer" = mkIf cfg.agent {
      file = ../../secrets/shared-bouncer.age;
      owner = "root";
      mode = "0400";
    };

    # --- CrowdSec Engine ---
    services.crowdsec = mkIf (!cfg.agent || isLogForwarder) {
      enable = true;
      name = config.networking.hostName;
      acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          labels.type = "syslog";
        }
      ]
      ++ cfg.acquisitions;
      enrollKeyFile = mkIf (!cfg.agent) cfg.enrollKeyFile;
      settings.api.server = mkIf (!cfg.agent) {
        listen_uri = "0.0.0.0:${toString lapiPort}";
        trusted_ips = [
          "127.0.0.1"
          "100.64.0.0/10"
        ];
      };
      settings.api.client.credentials = mkIf isLogForwarder {
        url = lapiUri;
        login = config.networking.hostName;
        password_path = cfg.machinePasswordFile;
      };
    };

    # --- Firewall Bouncer ---
    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = if cfg.agent then lapiUri else "http://127.0.0.1:${toString lapiPort}";
        api_key = "\${BOUNCER_API_KEY}";
      };
    };

    systemd.services = {
      crowdsec-firewall-bouncer = {
        after = [ "tailscale.service" ] ++ lib.optionals (!cfg.agent) [ "crowdsec.service" ];
        serviceConfig.EnvironmentFile =
          if cfg.agent then config.age.secrets."shared-bouncer".path else cfg.bouncerApiKeyFile;
      };

      crowdsec = {
        after = [ "tailscale.service" ];
      };
    };
  };
}
