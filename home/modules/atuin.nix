{...}: {
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];

    settings = {
      auto_sync = true;
      sync_address = "https://atuin.thuis.plebian.nl";
      sync_frequency = "10m";
      update_check = false;
      style = "compact";
      zsh = {
        enable = true;
        enableCompletion = false;
      };
    };
  };
}
