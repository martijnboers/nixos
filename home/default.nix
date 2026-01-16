{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";
  home.stateVersion = "24.05";

  imports = [
    ./modules/nixvim.nix
    ./modules/stylix.nix
    ./modules/attic.nix
    ./modules/aerc.nix
    ./modules/khal.nix
    ./modules/zsh.nix
    ./modules/mods.nix

    # Packaged home manager modules
    inputs.nixvim.homeModules.nixvim
    inputs.stylix.homeModules.stylix
    inputs.walker.homeManagerModules.default

    # Quickly lookup and run programs
    inputs.nix-index-database.homeModules.nix-index

    # Secrets manager
    inputs.agenix.homeManagerModules.default

    # Desktop only
    ./modules/hyprland.nix
    ./modules/browser.nix
    ./modules/ghostty.nix
  ];

  # User level packages
  home.packages = with pkgs; [
    gemini-cli # proompting
    claude-code # proompting
    tldr # man summarized
  ];

  # User level secrets
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    secrets = {
      llm.file = ../secrets/llm.age;
    };
  };

  # Default mimetype associations
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      associations.removed = {
        "application/zip" = "org.pwmt.zathura-cb.desktop";
      };
      defaultApplications =
        let
          mkMimeAssoc = mimeTypes: desktopFile: lib.attrsets.genAttrs mimeTypes (mimeType: desktopFile);
          imageMimeTypes = [
            "image/jpeg"
            "image/png"
            "image/gif"
            "image/bmp"
            "image/tiff"
            "image/webp"
            "image/x-icon"
            "image/heif"
            "image/heic"
            "image/avif"
          ];
          htmlTypes = [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "text/html"
          ];
        in
        {
          # ls ~/.nix-profile/share/applications
          "text/plain" = "org.xfce.mousepad.desktop";
          "application/pdf" = "org.pwmt.zathura.desktop";
          "inode/directory" = "thunar.desktop";
          "text/calendar" = "khal.desktop";
        }
        // mkMimeAssoc imageMimeTypes "imv.desktop"
        // mkMimeAssoc htmlTypes "librewolf.desktop";
    };
  };

  # Let nix-index handle command-not-found
  programs.nix-index.enable = true;

  # Run programs with , cowsay
  programs.nix-index-database.comma.enable = true;

  # By default get full zsh+nixvim config
  maatwerk.zsh.enable = lib.mkDefault true;
  maatwerk.nixvim.enable = lib.mkDefault true;

  programs.git = {
    enable = true;
    signing = {
      signByDefault = true;
      key = lib.mkDefault "key::${lib.fileContents ../secrets/keys/keychain-sk.pub}";
      format = "ssh";
    };
    settings = {
      pull.rebase = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      user.name = "Martijn Boers";
      user.email = "martijn@boers.email";
      delta = {
        navigate = true;
        dark = true;
      };
      merge.conflictStyle = "zdiff3";
      pager = {
        blame = "delta";
        diff = "delta";
        reflog = "delta";
        show = "delta";
      };
    };
  };

  # Delta git diff highlighter
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
