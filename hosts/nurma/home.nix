{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.veracrypt

    # SDR
    gqrx
    sdrpp

    # yubikey
    yubioath-flutter
    yubico-piv-tool
    yubikey-manager # ykman
    opensc
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  programs.git = {
    extraConfig.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";
    signing.signByDefault = true;
  };

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
