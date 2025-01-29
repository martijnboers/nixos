{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.maatwerk.vscode;
in {
  options.maatwerk.vscode = {
    enable = mkEnableOption "Vscode editor";
  };
  config = mkIf cfg.enable {
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
        # devsense.phptools-vscode

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
        {
          "key" = "ctrl+p";
          "command" = "editor.action.addSelectionToNextFindMatch";
          "when" = "editorFocus";
        }
        {
          "key" = "ctrl+shift+enter";
          "command" = "workbench.action.navigateBackInEditLocations";
        }
      ];
      userSettings = {
        "editor.fontSize" = lib.mkForce 16;
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
        "typos.diagnosticSeverity" = "info"; # don't show warnings for typos
        extensions.autoCheckUpdates = false;
        extensions.autoUpdate = false;
        explorer.confirmDragAndDrop = false;
      };
    };
  };
}
