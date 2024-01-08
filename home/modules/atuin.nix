{...}: {
  programs.atuin = {
    enable = true;
    flags = ["--disable-ctrl-r" "--disable-up-arrow"];

    settings = {
      auto_sync = true;
      sync_address = "https://atuin.plebian.nl";
      sync_frequency = "10m";
      update_check = false;
      zsh = {
        enable = true;
        enableCompletion = false;
      };
    };
  };
}
