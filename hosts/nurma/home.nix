{
  pkgs,
  ...
}:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.sdrpp # sdr
    # electrum
    android-tools
  ];

  programs.yt-dlp.enable = true;
  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
