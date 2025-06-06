{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.proxy;
in
{
  options.hosts.proxy = {
    enable = mkEnableOption "socks proxies";
  };

  config = mkIf cfg.enable {
    services.date = {
      enable = true;
      config = ''
        #errorlog: /var/log/sockd.errlog
        logoutput: /var/log/sockd.log
        #debug: 2

        #server address specification
        internal: ${config.hidden.tailscale_hosts.shoryuken} port = 1188
        external: eth1

        #server identities (not needed on solaris)
        #user.privileged: root
        user.notprivileged: socks
        #user.libwrap: libwrap

        #reverse dns lookup
        #srchost: nodnsmismatch

        #authentication methods
        clientmethod: none
        socksmethod: none

        ##
        ## SOCKS client access rules
        ##
        #rule processing stops at the first match, no match results in blocking

        #block access to socks server from 192.0.2.22 (exception for pass rule below)
        # client block {
        #       #block connections from 192.0.2.22/32
        #       from: 192.0.2.22/24 to: 0.0.0.0/0
        #       log: error # connect disconnect
        # }

        #allow connections from local network (192.0.2.0/24)
        client pass {
                from: 192.0.2.0/24 to: 0.0.0.0/0
        	log: error # connect disconnect
        }

        ##
        ## SOCKS command rules
        ##
        #rule processing stops at the first match, no match results in blocking

        #block communication with www.example.org
        # socks block {
        #        from: 0.0.0.0/0 to: www.example.org
        #        command: bind connect udpassociate
        #        log: error # connect disconnect iooperation
        # }

        #generic pass statement - bind/outgoing traffic
        socks pass {  
                from: 0.0.0.0/0 to: 0.0.0.0/0
                command: bind connect udpassociate
                log: error # connect disconnect iooperation
        }

        #block incoming connections/packets from ftp.example.org 
        # socks block {
        #        from: ftp.example.org to: 0.0.0.0/0
        #        command: bindreply udpreply
        #        log: error # connect disconnect iooperation
        # }

        #generic pass statement for incoming connections/packets
        socks pass {
                from: 0.0.0.0/0 to: 0.0.0.0/0
                command: bindreply udpreply
                log: error # connect disconnect iooperation
        }

      '';
    };
  };
}
