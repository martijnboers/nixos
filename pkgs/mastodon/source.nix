/*
  This fetches the glitch-soc source from GitHub and patches it.

  This needs to be a separately buildable package so that update.sh can build it during upgrading,
  because it needs it for generating `gemset.nix` from the Gemfile in the source.
*/

{
  applyPatches,
  fetchFromGitHub,
  lib,
}:

let
  versionData = import ./version_data.nix;
in
applyPatches {
  src = fetchFromGitHub {
    owner = "glitch-soc";
    repo = "mastodon";
    inherit (versionData) rev hash;
  };
  patches = lib.filesystem.listFilesRecursive ./patches;
}
