{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [gqrx sway wmenu];

  age.identityPaths = ["/home/martijn/.ssh/id_ed25519_age"];
  programs.git.extraConfig.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";

  # Enable profiles
  maatwerk.hyprland.enable = true;
  maatwerk.personal.enable = true;
  maatwerk.work.enable = true;
}
