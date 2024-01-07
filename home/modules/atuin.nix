{...}: {
   programs.atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        sync_address = "https://atuin.plebian.nl";
        sync_frequency = "10m";
        update_check = false;
        workspaces = true;
        flags = ["--disable-ctrl-r"];
      };
    };
}
