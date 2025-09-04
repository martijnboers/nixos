{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    gqrx
    sway
    wmenu

    openssl # for internal pki certs
    xca
    stable.veracrypt

    # yubikey
    yubioath-flutter
    yubico-piv-tool
    yubikey-manager # ykman
    opensc
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];
  programs.git.extraConfig.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
