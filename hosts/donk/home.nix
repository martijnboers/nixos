{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.veracrypt

    # yubikey
    yubioath-flutter
    yubico-piv-tool
    yubikey-manager # ykman
    opensc
  ];

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
