{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.nixvim;
  helpers = config.lib.nixvim;
in
{
  config = mkIf cfg.enable {
    programs.nixvim = {
      plugins = {
        dap-virtual-text.enable = true;
        dap-python = {
          enable = true;
          settings.includeConfigs = true;
        };

        dap-view = {
          enable = true;
          settings = {
            winbar = {
              sections = [
                "scopes"
                "repl"
                "watches"
                "breakpoints"
                "console"
              ];
              controls.enabled = true;
            };
          };
        };

        dap = {
          enable = true;
          luaConfig.post = # lua
            ''
              local dap, dv = require("dap"), require("dap-view")
              dap.listeners.before.attach["dap-view-config"] = function()
                  dv.open()
              end
              dap.listeners.before.launch["dap-view-config"] = function()
                  dv.open()
              end
              dap.listeners.before.event_terminated["dap-view-config"] = function()
                  dv.close()
              end
              dap.listeners.before.event_exited["dap-view-config"] = function()
                  dv.close()
              end
            '';
          signs = {
            dapBreakpoint.text = "●";
            dapBreakpointCondition.text = "";
            dapLogPoint.text = "◆";
          };
        };
      };

      keymaps = [
        {
          action = "<cmd>DapViewToggle<cr>";
          key = "<Leader>dd";
        }
        {
          action = "<cmd>DapToggleBreakpoint<cr>";
          key = "<Leader>da";
        }
        {
          action = helpers.mkRaw ''
            function() 
              local dap = require('dap') 
              dap.toggle_breakpoint(vim.fn.input('Condition: ')) 
            end
          '';
          key = "<Leader>dc";
        }
        {
          action = "<cmd>DapContinue<cr>";
          key = "<F1>";
        }
        {
          action = "<cmd>DapStepInto<cr>";
          key = "<F2>";
        }
        {
          action = "<cmd>DapStepOver<cr>";
          key = "<F3>";
        }
        {
          action = "<cmd>DapStepOut<cr>";
          key = "<F4>";
        }
        {
          action = "<cmd>DapStepBack<cr>";
          key = "<F5>";
        }
        {
          action = "<cmd>DapNew<cr>";
          key = "<F6>";
        }
        {
          action = helpers.mkRaw ''
            function() 
              local dap = require('dap') 
              dap.run_last() 
            end
          '';
          key = "<F7>";
        }
      ];
    };
  };
}
