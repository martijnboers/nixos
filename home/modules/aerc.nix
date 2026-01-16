{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.aerc;
  c = config.lib.stylix.colors;
in
{
  options.maatwerk.aerc = {
    enable = mkEnableOption "Email client";
  };

  config = mkIf cfg.enable {
    programs.mbsync.enable = true;

    programs.notmuch = {
      enable = true;
      new.tags = [ "new" ];
    };

    services.mbsync = {
      enable = true;
      frequency = "*:0/2";
      postExec = "${lib.getExe pkgs.notmuch} new";
    };

    programs.aerc = {
      enable = true;

      stylesets.kanagawa_custom = ''
        # --- GLOBAL ---
        *.bg = #${c.base00}
        *.fg = #${c.base05}

        # --- UI ELEMENTS ---
        title.bg = #${c.base00}
        title.fg = #${c.base0D}
        title.bold = true

        border.fg = #${c.base03}
        border.bg = #${c.base00}

        statusline_default.bg = #${c.base01}
        statusline_default.fg = #${c.base05}

        statusline_error.fg = #${c.base00}
        statusline_error.bg = #${c.base08}

        # --- MESSAGE LIST ---
        msglist_default.bg = #${c.base00}
        msglist_default.fg = #${c.base05}

        # FIX: Use .selected modifier instead of msglist_selected
        msglist_default.selected.bg = #${c.base02}
        msglist_default.selected.fg = #${c.base05}
        msglist_default.selected.bold = true

        msglist_unread.fg = #${c.base0E}
        msglist_unread.bold = true

        # --- VIEWER SECTION ---
        [viewer]
        header.fg = #${c.base0D}
        header.bold = true

        url.fg = #${c.base0C}
        url.underline = true

        signature.fg = #${c.base03}

        quote_1.fg = #${c.base0B}
        quote_2.fg = #${c.base0A}
      '';

      extraConfig = {
        general.unsafe-accounts-conf = true;
        ui = {
          sort = "-r date";
          timestamp-format = "2006-01-02 15:04";

          styleset-name = "kanagawa_custom";
          border-char-vertical = "│";
          border-char-horizontal = "─";
        };
        filters = {
          "text/plain" = "${lib.getExe pkgs.bat} -fP --style=plain";
          "text/html" = "${lib.getExe pkgs.w3m} -dump -T text/html";
          "text/calendar" = "${lib.getExe pkgs.bat} -fP --style=plain";
          "application/pdf" = "${pkgs.poppler-utils}/bin/pdftotext - -";
        };
      };
    };

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
        extraAccounts = {
          source = "maildir://~/Maildir/Proton";
          outgoing = "smtp+plain://martijn%40boers.email@hadouken.machine.thuis:1025";
          check-mail-cmd = "${pkgs.isync}/bin/mbsync proton";
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
