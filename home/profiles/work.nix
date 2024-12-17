{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.thuis.work;
  teamsScript = pkgs.writeShellApplication {
    name = "teams";
    runtimeInputs = [pkgs.ungoogled-chromium];
    text = ''
      chromium --new-tab https://teams.microsoft.com/
    '';
  };
  teamsDesktopItem = pkgs.makeDesktopItem {
    name = "teams";
    exec = getExe teamsScript;
    desktopName = "Microsoft Teams";
    genericName = "Business Communication";
    comment = "Microsoft Teams as Chromium web app.";
    startupWMClass = "teams";
    terminal = true;
  };
in {
  options.thuis.work = {
    enable = mkEnableOption "Enable packages and configuration specific to work";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jetbrains.pycharm-community
      jetbrains.webstorm
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      go
      httpie-desktop
      distrobox # run any linux distro

      teamsDesktopItem
      teamsScript
      (citrix_workspace.override {version = "24.8.0.98";})
    ];

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        jnoortheen.nix-ide

        redhat.vscode-yaml
        zainchen.json
        yzhang.markdown-all-in-one
        ms-python.python
        ms-python.black-formatter
        devsense.phptools-vscode

        hashicorp.terraform
        ms-azuretools.vscode-docker

        eamodio.gitlens
        tekumara.typos-vscode
        formulahendry.code-runner
        vscode-icons-team.vscode-icons
        pkief.material-icon-theme
      ];
      keybindings = [
        {
          "key" = "ctrl+alt+v";
          "command" = "toggleVim";
        }
      ];
      userSettings = {
        "editor.fontSize" = 16;
        "editor.formatOnPaste" = true;
        "editor.cursorBlinking" = "smooth";
        "editor.fontLigatures" = true;

        "files.autoSave" = "onFocusChange"; # always save files
        "window.menuBarVisibility" = "toggle";
        "workbench.iconTheme" = "material-icon-theme";

        python.formatting.provider = "black";
        git.autofetch = true;

        "vim.handleKeys" = {
          "<C-s>" = false; # regular save
          "<C-z>" = false; # redo
          "<C-e>" = false; # open find file window
          "<C-f>" = false; # regular search
          "<C-b>" = false; # close side panel
          "<C-w>" = false; # close active panel
        };

        "typos.logLevel" = "info"; # don't show warnings for typos
        extensions.autoCheckUpdates = false;
        extensions.autoUpdate = false;
        explorer.confirmDragAndDrop = false;
      };
    };
  };
}
