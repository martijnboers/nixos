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
          threading-enabled = true;
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

    xdg.configFile."aerc/binds.conf".text = ''
      gt = :next-tab<Enter>
      gT = :prev-tab<Enter>
      ? = :help keys<Enter>

      [messages]
      R = :check-mail<Enter>
      q = :quit<Enter>
      <C-c> = :quit<Enter>
      / = :filter<space>

      k = :prev<Enter>
      j = :next<Enter>

      <C-d> = :next 50%<Enter>
      <C-u> = :prev 50%<Enter>
      gg = :select 0<Enter>
      G = :select -1<Enter>
      V = :mark -V<Enter>
      J = :next-folder<Enter>
      K = :prev-folder<Enter>
      <Space> = :mark -t<Enter>:next<Enter>

      T = :toggle-threads<Enter>
      C = :compose<Enter>

      <Enter> = :view<Enter>
      D = :delete<Enter>
      A = :archive flat<Enter>

      rr = :reply -a<Enter>
      rq = :reply -aq<Enter>
      Rr = :reply<Enter>
      Rq = :reply -q<Enter>

      c = :move<space>
      <Backspace> = :clear<Enter>

      <C-s> = :split<Enter>
      <C-v> = :vsplit<Enter>

      [messages:folder=Drafts]
      <Enter> = :recall<Enter>

      [view]
      / = :toggle-key-passthrough<Enter>/
      q = :close<Enter>
      x = :close<Enter>
      o = :open<Enter>
      S = :save<space>
      D = :delete<Enter>
      A = :archive flat<Enter>

      <C-y> = :copy-link <space>
      <C-l> = :open-link <space>

      f = :forward<Enter>
      rr = :reply -a<Enter>
      rq = :reply -aq<Enter>
      Rr = :reply<Enter>
      Rq = :reply -q<Enter>

      H = :toggle-headers<Enter>
      <C-k> = :prev-part<Enter>
      <C-j> = :next-part<Enter>
      J = :next<Enter>
      K = :prev<Enter>

      [view::passthrough]
      $noinherit = true
      $ex = <C-x>
      <Esc> = :toggle-key-passthrough<Enter>

      [compose]
      $noinherit = true
      $ex = <C-x>
      <tab> = :next-field<Enter>
      <backtab> = :prev-field<Enter>

      [compose::editor]
      # Keybindings used when the embedded terminal is selected in the compose view
      $noinherit = true
      $ex = <C-x>

      [compose::review]
      # Keybindings used when reviewing a message to be sent
      # Inline comments are used as descriptions on the review screen
      y = :send<Enter> # Send
      n = :abort<Enter> # Abort (discard message, no confirmation)
      s = :sign<Enter> # Toggle signing
      q = :choose -o d discard abort -o p postpone postpone<Enter> # Abort or postpone
      e = :edit<Enter> # Edit (body and headers)
      a = :attach<space> # Add attachment
      d = :detach<space> # Remove attachment

      [terminal]
      $noinherit = true
      $ex = <C-x>
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
