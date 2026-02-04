{ ... }:
{
  age.secrets = {
    llm.file = ../../secrets/llm.age;
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
          # https://docs.anthropic.com/en/docs/about-claude/models
          type = "claude";
        }
        {
          type = "openai-compatible";
          name = "vllm";
          api_base = "http://localhost:5000/v1";
        }
      ];
    };
  };

  programs.zsh = {
    # aichat expects "GOOGLE_API_KEY" specifically for Gemini.
    # We map your existing GEMINI_API_KEY to it here.
    sessionVariables = {
      GOOGLE_API_KEY = "$GEMINI_API_KEY";
    };

    shellAliases = {
      "c?" = "aichat -m gemini:gemini-3-flash-preview -e";
      "w?" = "aichat -c";
    };
  };
}
