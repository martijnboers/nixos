{ ... }:
{
  age.secrets = {
    llm.file = ../../secrets/llm.age;
  };

  programs.opencode = {
    enable = true;
    rules = ''
      The system is running NixOS meaning you can't edit all config files and some changes require a `nixos-rebuild switch`. Keep this into account
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
          "rm -rf *" = "deny";
          "git push --force" = "deny";
          "git push -f" = "deny";
          "git push origin --force" = "deny";
          "git push origin -f" = "deny";
        };
      };
      tools = {
        write = true;
        edit = true;
        bash = true;
      };
      keybinds = {
        editor_open = "ctrl+o";
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
          name = "deepseek";
          api_base = "https://api.deepseek.com";
        }
        {
          type = "openai-compatible";
          name = "vllm";
          api_base = "http://localhost:5000/v1";
        }
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://localhost:11434/v1";
        }
      ];
    };
  };

  programs.zsh = {
    sessionVariables = {
      GOOGLE_API_KEY = "$GEMINI_API_KEY";
      GOOGLE_GENERATIVE_AI_API_KEY = "$GEMINI_API_KEY";
    };

    shellAliases = {
      "c?" = "aichat -m gemini:gemini-3-flash-preview -e";
      "w?" = "aichat -c";
    };
  };
}
