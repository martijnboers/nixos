{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # prev = unaltered (before overlays)
  # final = after overlay mods, like rec keyword
  modifications = final: prev: {
    # strawberry = prev.strawberry.overrideAttrs (oldAttrs: {
    #   # Set the flags to prevent stripping
    #   dontStrip = true;
    #   dontPatchELF = true;
    #   cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [ "-DCMAKE_BUILD_TYPE=Debug" ];
    # });
    # karlender = prev.karlender.overrideAttrs (oldAttrs: {
    #   patches = (oldAttrs.patches or [ ]) ++ [
    #     ./sync.rs.patch
    #   ];
    # });
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  alternative-pkgs = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
