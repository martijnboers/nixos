{...}: {
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    enableZshIntegration = true;

    settings = {
      auto_sync = true;
      sync_address = "https://atuin.thuis";
      sync_frequency = "10m";
      update_check = false;
      style = "compact";
      sync.records = true;
    };
  };
}
