{
  inputs,
  outputs,
  system,
  pkgs,
  ...
}: {
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "24.05";

  imports = [
    ./modules/stylix.nix
    ./modules/nixvim.nix
    ./modules/atuin.nix
    ./modules/zsh.nix

    # Packaged home manager modules
    inputs.nixvim.homeManagerModules.nixvim
    inputs.stylix.homeManagerModules.stylix

    # quickly lookup and run programs
    inputs.nix-index-database.hmModules.nix-index

    # secrets manager
    inputs.agenix.homeManagerModules.default

    # Desktop only
    ./modules/hyprland.nix
    ./modules/browser.nix
    ./modules/vscode.nix
    ./modules/kitty.nix
    ./modules/kde.nix
    inputs.plasma-manager.homeManagerModules.plasma-manager

    # profiles based on type of computer usage
    ./profiles/personal.nix
    ./profiles/work.nix
  ];

  # Global user level packages
  home.packages = with pkgs; [
    # shell
    zsh-powerlevel10k
    zoxide
    fzf # A command-line fuzzy finder
    fd # easier find
    direnv # used for .envrc files
    yazi # like ranger
    neofetch
    thefuck
    trash-cli
    bat # fancy cat
    lsd # fancy ls
    magic-wormhole # send files
    hydra-check # lookup hydra status binary

    # system
    gnupg
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    tldr # man summarized
    killall # 🔪
    btop # fancy htop
    nerdfonts # icon font

    # archives
    zip
    unzip
    p7zip

    # tools
    mods # ai for cli
    glow # cli markdown viewer
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

  home.file.".config/mods/mods.yml" = {
    source = ./config/mods.yml;
  };

  # Let nix-index handle command-not-found
  programs.nix-index.enable = true;
  # Run programs with , cowsay
  programs.nix-index-database.comma.enable = true;

  # By default get full zsh config
  maatwerk.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "Martijn Boers";
    userEmail = "martijn@plebian.nl";
    signing = {
      key = "328144ACADA0A336";
      signByDefault = true;
    };
    extraConfig = {
      pull.rebase = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      safe.directory = "/home/martijn/Nix/.git"; # Doesnt work with nixos https://discourse.nixos.org/t/nixos-rebuild-switch-fails-under-flakes-and-doas-with-git-warning-about-dubious-ownership/46069/11?u=martijn
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
