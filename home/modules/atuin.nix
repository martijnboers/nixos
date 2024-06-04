{...}: {
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    enableZshIntegration = true;

    settings = {
      auto_sync = true;
      sync_address = "https://atuin.thuis.plebian.nl";
      sync_frequency = "10m";
      update_check = false;
      style = "compact";
      sync.records = true;
    };
  };
}
