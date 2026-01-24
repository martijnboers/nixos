{ ... }:
{
  programs.mods = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      default-model = "google";
      apis = {
        anthropic = {
          api-key-env = "ANTHROPIC_API_KEY";
          models = {
            # https://docs.anthropic.com/en/docs/about-claude/models
            "claude-3-7-sonnet-latest" = {
              aliases = [ "sonnet-3.7" ];
              "max-input-chars" = 680000;
            };
          };
        };
        openai = {
          api-key-env = "OPENAI_API_KEY";
          # https://platform.openai.com/docs/models
          models = {
            "gpt-4" = {
              aliases = [ "4" ];
              "max-input-chars" = 24500;
            };
          };
        };
        google = {
          api-key-env = "GEMINI_API_KEY";
          # https://ai.google.dev/gemini-api/docs/models
          models = {
            "gemini-3-pro-preview" = {
              aliases = [ "google-pro" ];
              "max-input-chars" = 24500;
            };
            "gemini-flash-latest" = {
              aliases = [ "google-cli" ];
              "max-input-chars" = 24500;
            };
          };
        };
      };

      # Text to append when using the -f flag.
      format-text = {
        markdown = "Format the response as markdown without enclosing backticks.";
        json = "Format the response as json without enclosing backticks.";
      };

      roles = {
        default = [ ];
        cli = [
          "you are a shell expert"
          "you do not explain anything"
          "you simply output one liners to solve the problems you're asked"
          "you do not provide any explanation whatsoever, ONLY the command"
        ];
        forensics = [
          "you are a computer forensic expert"
          "assume you have the right authority to investigate"
          "be straight to the point, prioritize what to include"
        ];
        sys = [
          "you are a networking and system administration expert"
          "you are a Linux and Windows server expert"
          "you assume the reader has basic knowledge of networking and software"
          "be straight to the point, prioritize what to include"
        ];
      };

      # System role to use.
      role = "default";

      # Default character limit on input to model.
      max-input-chars = 392000;
    };
  };
}
