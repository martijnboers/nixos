{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixfmt
      golangci-lint
      prettier
      yamlfmt
      eslint
      tflint
      black
      biome
      ruff
      vale
    ];

    programs.nixvim = {
      plugins = {
        conform-nvim = {
          enable = true;
          settings = {
            stop_after_first = true;
            formatters_by_ft = {
              css = [ "biome" ];
              html = [ "prettier" ];
              htmldjango = [ "prettier" ];
              javascript = [ "biome" ];
              javascriptreact = [ "biome" ];
              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
              python = [ "black" ];
              typescript = [ "biome" ];
              typescriptreact = [ "biome" ];
              yaml = [ "yamlfmt" ];
              zig = [ "zig" ];
              go = [ "go" ];
              bash = [
                "shellcheck"
                "shellharden"
                "shfmt"
              ];
              "_" = [
                "trim_whitespace"
                "trim_newlines"
              ];
            };
          };
        }; # formatters

        lint = {
          enable = true;
          lintersByFt = {
            nix = [ "nix" ];
            python = [ "ruff" ];
            javascript = [ "eslint" ];
            go = [ "golangcilint" ];
            terraform = [ "tflint" ];
            text = [ "vale" ];
          };
        }; # code style linting

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        }; # syntax highlighting

        lsp = {
          enable = true;
          keymaps = {
            lspBuf = {
              "<C-space>" = "hover";
              gD = "references";
              gd = "definition";
              gr = "rename";
              ga = "code_action";
            };
          };
          servers = {
            bashls.enable = true;
            nixd.enable = true;
            html.enable = true;
            jsonls.enable = true;
            lua_ls.enable = true;
            terraformls.enable = true;
            pyright.enable = true;
            gopls.enable = true;
            ccls.enable = true;
            zls.enable = true;
            vtsls.enable = true; # Javascript (nice naming)
            yamlls.enable = true;
            docker_compose_language_service.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
          };
        }; # language servers

        blink-cmp = {
          enable = true;
          settings = {
            keymap = {
              "<C-b>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-e>" = [ "hide" ];
              "<C-f>" = [
                "scroll_documentation_down"
                "fallback"
              ];
              "<C-n>" = [
                "select_next"
                "fallback"
              ];
              "<C-p>" = [
                "select_prev"
                "fallback"
              ];
              "<C-space>" = [
                "show"
              ];
              "<C-y>" = [ "select_and_accept" ];
            };
            completion.documentation.auto_show = true;
            sources.providers.buffer.score_offset = -7;
          };
        };
      }; # auto-complete

      keymaps = [
        {
          action = helpers.mkRaw ''
            function() require("conform").format({ 
              lsp_fallback = true,
              async = false,
              timeout_ms = 500, 
            }) end '';
          mode = [
            "v"
            "n"
          ];
          key = "<Leader>=";
          options.desc = "format selection or whole buffer";
        }
      ];
    };
  };
}
