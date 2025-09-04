{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # prev = unaltered (before overlays)
  # final = after overlay mods, like rec keyword
  modifications = final: prev: {
    # customplex = prev.plex.override {
    #   plexRaw = prev.plexRaw.overrideAttrs (old: rec {
    #     pname = "plexmediaserver";
    #     version = "1.42.1.10060-4e8b05daf";
    #     src = prev.fetchurl {
    #       url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
    #       sha256 = "sha256:1x4ph6m519y0xj2x153b4svqqsnrvhq9n2cxjl50b9h8dny2v0is";
    #     };
    #     passthru = old.passthru // {
    #       inherit version;
    #     };
    #   });
    # };
    #
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  alternative-pkgs = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
    # fork = import inputs.nixpkgs-fork {
    #   system = final.system;
    #   config.allowUnfree = true;
    # };
  };
}
