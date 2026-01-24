{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.aerc;
in
{
  options.maatwerk.aerc = {
    enable = mkEnableOption "Email client";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.notmuch
      pkgs.notmuch-addrlookup
    ];

    programs.notmuch = {
      enable = true;
      new.tags = [
        "new"
        "inbox"
        "unread"
      ];
      extraConfig = {
        database.path = "${config.home.homeDirectory}/Maildir";
        maildir.synchronize_flags = "true";
      };
    };

    programs.mbsync.enable = true;
    services.mbsync = {
      enable = true;
      frequency = "*:0/2"; # Run every 2 minutes
      postExec = "${lib.getExe pkgs.notmuch} new";
    };

    programs.aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;
        ui = {
          sort = "-r date";
          timestamp-format = "2006-01-02 15:04";
        };
        # Use Notmuch only for autocompleting email addresses
        compose.address-book-cmd = "${lib.getExe pkgs.notmuch-addrlookup} --format=aerc %s";

        filters = {
          "text/plain" = "${lib.getExe pkgs.bat} -fP --style=plain";
          "text/html" = "${lib.getExe pkgs.w3m} -dump -T text/html";
          "application/pdf" = "${pkgs.poppler-utils}/bin/pdftotext - -";
        };
        openers = {
          "text/html" = "xdg-open";
          "application/pdf" = "xdg-open";
        };
      };
    };

    xdg.configFile."aerc/binds.conf".text = builtins.readFile "${pkgs.aerc}/share/aerc/binds.conf" + ''
      [messages]
      R = :check-mail<Enter>
      q = :quit<Enter>
      / = :filter 
      [view]
      O = :open<Enter>
    '';

    age.secrets.proton.file = ../../secrets/proton.age;

    accounts.email.accounts.proton = {
      primary = true;
      realName = "Martijn Boers";
      address = "martijn@boers.email";
      userName = "martijn@boers.email";
      maildir.path = "Proton";

      gpg = {
        key = "C1E3 5670 353B 3516 BAA3 51D2 8BA2 F86B 654C 7078";
        signByDefault = true;
      };

      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        remove = "both";
        patterns = [
          "*"
          "!Folders/gmail"
          "!Folders/gmail/*"
          "!'All Mail'"
        ];
      };

      notmuch.enable = true;

      aerc = {
        enable = true;
        extraAccounts = rec {
          source = "maildir://~/Maildir/Proton";
          # Prevents "File not found" errors when background sync renames files
          cache-headers = false;
          folders = "Inbox,Sent,Folders/signups,Folders/shipping,Folders/bewaren,Folders/werk,Drafts,Archive,Spam,Trash";
          folders-sort = folders;
          outgoing = "smtp+plain://martijn%40boers.email@hadouken.machine.thuis:1025";
          copy-to = "Sent";
          check-mail-cmd = "${pkgs.isync}/bin/mbsync proton";
          check-mail = "1m";
        };
      };

      imap = {
        host = "hadouken.machine.thuis";
        port = 1143;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };

      smtp = {
        host = "hadouken.machine.thuis";
        port = 1025;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };

      passwordCommand = "cat ${config.age.secrets.proton.path}";
    };
  };
}
