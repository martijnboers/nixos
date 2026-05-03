{
  inputs,
  lib,
  config,
  ...
}:
{
  age.secrets = {
    llm.file = "${inputs.secrets}/llm.age";
  };

  programs.opencode = {
    enable = true;
    tui = {
      keybinds = {
        editor_open = "ctrl+o";
        messages_next = "ctrl+j";
        messages_previous = "ctrl+k";
        messages_last = "ctrl+b";
        command_list = "ctrl+l";
      };
    };
    rules = ''
      # SYSTEM CONTEXT & OPERATIONAL CONSTRAINTS

      ## OS Architecture: NixOS
      **Context:** 
        The system is NixOS. The file system is declarative and largely
        immutable.
      **Constraint:** 
        **DO NOT** attempt to modify system files (e.g., in `/etc/`) directly
        using standard Linux commands. 
      **Action:** 
        To change system configurations, you must edit the relevant declarative
        configuration files (e.g., `devenv.nix`, `flake.nix`) and execute
        `nixos-rebuild switch`. You can run one off commands that are not in
        path with `nix shell nixpkgs#cat` or `, cat`. 

      **Context**
        /nix/store is very, very big. 
      **Constraint**
        **!!NEVER EVER NEVER EVER!!** try to use `find` to look for binaries or
        libraries in /nix/store. If I catch you, you have to say sorry three
        times
      **Action**
        If you want to look for something, **!!USE NIX-LOCATE!!**, it's much faster as
        it has indexed the whole store. 

      ## Enviroment
      **Context:** 
        I debug on computers for servers on desktops. Very often I will create
        code/services that's not being run on the computer running opencode
      **Constraint:** 
        DO NOT keep on trying to find running services when they are not on the
        system.
      **Action:** 
        ASK if the code/service you're developing is for this machine or a
        machine you don't have access to. If it's for another machine DON'T TRY
        TO LOOK FOR FILES / INSTALL PROGRAMS ETC

      ## Source Truth & User Intent
      **Context:** 
        The user manually edits files between runs.
      **Rule:** 
        Treat missing code or removed functions as **INTENTIONAL** deletions by
        the user.
      **Constraint:** 
        NEVER re-add code that appears to have been removed since the last run.
      **Exception:** 
        If a removal causes a critical failure, **ASK** the user before
        attempting to restore it.

      ## File Operations
      **Decision Tree for Cloning Repositories:**
        IF the task is for development, persistence, or repeated use -> Clone to `~/Code`.
        IF the task is temporary, one-off, or for inspection -> Clone to `/tmp`.

      **Decision Tree for test files**
        IF the path is tracked by git -> put test files in /tmp/dirname
        IF the path is NOT tracked by git -> you can put test files directly in it

      ## General rules:
      - **DONT REMOVE COMMENTS** unless specificly asked. 
      - If you are in plan mode, **DONT REMIND ME**, this was intentional
    '';
    settings = {
      compaction = {
        auto = true;
        prune = true;
      };
      permission = {
        write = "allow";
        edit = "allow";
        bash = {
          "*" = "allow";
          "git commit*" = "ask";
          "git push*" = "ask";
          "nixos-rebuild *" = "ask";
          "nh *" = "ask";
          "rm -rf *" = "deny";
        };
      };
      tools = {
        write = true;
        edit = true;
        bash = true;
      };
      provider = {
        gemini = {
          options = {
            apiKey = "{env:GEMINI_API_KEY}";
          };
        };
        openai = {
          options = {
            apiKey = "{env:OPENAI_API_KEY}";
          };
        };
        anthropic = {
          options = {
            apiKey = "{env:ANTHROPIC_API_KEY}";
          };
        };
        moonshot-ai = {
          options = {
            apiKey = "{env:MOONSHOT_API_KEY}";
          };
        };
        deepseek = {
          npm = "@ai-sdk/openai-compatible";
          name = "DeepSeek";
          options = {
            baseURL = "https://api.deepseek.com";
            apiKey = "{env:DEEPSEEK_API_KEY}";
          };
        };
        vllm = {
          npm = "@ai-sdk/openai-compatible";
          name = "vLLM";
          options = {
            baseURL = "http://localhost:5000/v1";
          };
        };
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://localhost:11434/v1";
          };
          models = {
            "codellama:7b" = {
              name = "CodeLlama 7B";
            };
            "llama2:7b" = {
              name = "Llama 2 7B";
            };
            "mistral:7b" = {
              name = "Mistral 7B";
            };
            "qwen2.5-coder:7b" = {
              name = "Qwen2.5 Coder 7B";
            };
          };
        };
      };
    };
  };

  programs.aichat = {
    enable = true;
    settings = {
      model = "gemini:gemini-3-pro-preview";
      clients = [
        {
          # https://ai.google.dev/gemini-api/docs/models
          type = "gemini";
        }
        {
          # https://platform.openai.com/docs/models
          type = "openai";
        }
        {
          type = "openai-compatible";
          name = "moonshot";
          api_base = "https://api.moonshot.cn/v1";
        }
        {
          type = "openai-compatible";
          name = "deepseek";
          api_base = "https://api.deepseek.com";
        }
      ];
    };
  };

  programs.zsh = {
    shellAliases = {
      "c?" = "aichat -m gemini:gemini-3-flash-preview -e";
      "w?" = "aichat -c";
    };
  };
}
