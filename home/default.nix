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
    ./modules/neovim.nix
    ./modules/zsh.nix
    ./modules/atuin.nix
    ./modules/stylix.nix

    # Packaged home manager modules
    inputs.nixvim.homeManagerModules.nixvim

    # quickly lookup and run programs
    inputs.nix-index-database.hmModules.nix-index

    # secrets manager
    inputs.agenix.homeManagerModules.default

    # rice
    inputs.stylix.homeManagerModules.stylix

    # Desktop only
    ./modules/hyprland.nix
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

    # fonts
    meslo-lgs-nf
    nerdfonts

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
      openai.file = ../secrets/openai.age;
    };
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Let nix-index handle command-not-found
  programs.nix-index.enable = true;
  # Run programs with , cowsay
  programs.nix-index-database.comma.enable = true;

  # Additional direnv flake support
  programs.direnv.nix-direnv.enable = true;

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
      init.defaultBranch = "main"; # Doesnt work with nixos https://discourse.nixos.org/t/nixos-rebuild-switch-fails-under-flakes-and-doas-with-git-warning-about-dubious-ownership/46069/11?u=martijn
      push.autoSetupRemote = "true";
      safe.directory = "/home/martijn/Nix/.git";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
