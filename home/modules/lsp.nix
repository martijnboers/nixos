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
              K = "hover";
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
            vtsls.enable = true; # JavaScript (nice naming)
            yamlls.enable = true;
            markdown_oxide.enable = true;
            docker_compose_language_service.enable = true;
            harper_ls = {
              # https://writewithharper.com/docs/integrations/language-server
              enable = true; # Grammarly replacement
              settings = {
                linters = {
                  SentenceCapitalization = false;
                };
              };
            };
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
          };
        }; # language servers

        navic = {
          enable = true;
          settings = {
            lsp.auto_attach = true;
            depth_limit = 3;
            separator = " › ";
            highlight = false;
            safe_output = true;
          };
        }; # code context in statusline
      };

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
