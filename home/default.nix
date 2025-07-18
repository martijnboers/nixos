{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "24.05";

  imports = [
    ./modules/nixvim/default.nix
    ./modules/stylix.nix
    ./modules/atuin.nix
    ./modules/zsh.nix
    ./modules/mods.nix

    # Packaged home manager modules
    inputs.nixvim.homeManagerModules.nixvim
    inputs.stylix.homeModules.stylix

    # quickly lookup and run programs
    inputs.nix-index-database.hmModules.nix-index

    # secrets manager
    inputs.agenix.homeManagerModules.default

    # Desktop only
    ./modules/hyprland.nix
    ./modules/browser.nix
    ./modules/kitty.nix
  ];

  # Global user level packages
  home.packages = with pkgs; [
    # shell
    zsh-powerlevel10k
    zoxide
    fzf # A command-line fuzzy finder
    fd # easier find
    direnv # used for .envrc files
    yazi # cli file explorer
    neofetch
    bat # fancy cat
    lsd # fancy ls
    hydra-check # lookup hydra status binary
    gemini-cli # proompting

    # system
    gnupg
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    tldr # man summarized
    killall # 🔪
    btop # fancy htop
    hydra-check # check nixos ci builds

    # archives
    zip
    unzip
    p7zip
  ];

  # User level secrets
  age = {
    identityPaths = [
      "/home/martijn/.ssh/id_ed25519"
    ];
    secrets = {
      llm.file = ../secrets/llm.age;
    };
  };

  # Let nix-index handle command-not-found
  programs.nix-index = {
    enable = true;
  };
  # Run programs with , cowsay
  programs.nix-index-database.comma.enable = true;

  # By default get full zsh+nixvim config
  maatwerk.zsh.enable = lib.mkDefault true;
  maatwerk.nixvim.enable = lib.mkDefault true;

  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@boers.email";
    signing = {
      key = "328144ACADA0A336";
      signByDefault = true;
    };
    extraConfig = {
      pull.rebase = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
