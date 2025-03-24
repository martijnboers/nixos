{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    openssh # mac ssh doesn't support hardware keys
    qmk
    httpie
  ];

  age.identityPaths = ["/Users/martijn/.ssh/id_ed25519"];
  home.homeDirectory = lib.mkForce "/Users/martijn";
  home.file."Library/Application Support/mods/mods.yml" = {
    source = ../../home/config/mods.yml;
  };

  # Enable profiles
  maatwerk.kitty.enable = true;
  maatwerk.stylix.enable = true;
  maatwerk.vscode.enable = true;

  maatwerk.desktop.enable = false;
  maatwerk.personal.enable = false;
  maatwerk.work.enable = false;
}
