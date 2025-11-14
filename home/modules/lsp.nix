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
      tflint
      vale
      ruff
      eslint
      prettier
    ];

    programs.nixvim = {
      plugins = {
        conform-nvim = {
          enable = true;
          settings = {
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
            formatters = {
              black.command = lib.getExe pkgs.black;
              shellcheck.command = lib.getExe pkgs.shellcheck;
              shfmt.command = lib.getExe pkgs.shfmt;
              shellharden.command = lib.getExe pkgs.shellharden;
              nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
              stylua.command = lib.getExe pkgs.stylua;
              biome.command = "${lib.getExe pkgs.biome} format";
              prettier.command = lib.getExe pkgs.prettier;
              yamlfmt.command = lib.getExe pkgs.yamlfmt;
              zig.command = "${lib.getExe pkgs.zig} fmt";
            };
          };
        }; # formatters

        lint = {
          enable = true;
          lintersByFt = {
            nix = [ "nix" ];
            python = [ "ruff" ];
            javascript = [ "eslint" ];
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
        }; # Make vim understand syntax, but not like lsp

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
            enabled = helpers.mkRaw ''
              function()
                return vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
              end
            '';
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
                "show_documentation"
                "hide_documentation"
              ];
              "<C-y>" = [ "select_and_accept" ];
            };
            completion.documentation.auto_show = true;
            signature.enabled = true;
            sources.providers.buffer.score_offset = -7;
          };
        };
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
