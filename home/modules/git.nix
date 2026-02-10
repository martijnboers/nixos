{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    radicle-tui
  ];

  programs.git = {
    enable = true;
    signing = {
      signByDefault = true;
      key = lib.mkDefault "key::${lib.fileContents ../../secrets/keys/keychain-sk.pub}";
      format = "ssh";
    };
    settings = {
      pull.rebase = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      user.name = "Martijn Boers";
      user.email = "martijn@boers.email";
      alias = {
        patch = "push rad HEAD:refs/patches";
      };
      delta = {
        navigate = true;
        dark = true;
      };
      merge.conflictStyle = "zdiff3";
      pager = {
        blame = "delta";
        diff = "delta";
        reflog = "delta";
        show = "delta";
      };
    };
  };

  # Delta git diff highlighter
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  services.radicle.node.enable = true;
  programs.radicle = {
    enable = true;
    settings = {
      node = {
        alias = osConfig.networking.hostName;
        listen = [ "127.0.0.1:8776" ];
        proxy = "127.0.0.1:9050";
        onion.mode = "forward";
        connect = [ "z6MkhJKKVmjsA2MVrMMqMe2Au7bx8bUVtzWh2A9J3JWTeZAB@seed.boers.email:8776" ];
      };
    };
  };
}
