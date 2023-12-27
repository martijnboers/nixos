{
  lib,
  fetchurl,
  appimageTools,
}:
appimageTools.wrapType2 {
  name = "httpie-desktop";
  src = fetchurl {
    url = "https://github.com/httpie/desktop/releases/download/v2023.3.5/HTTPie-2023.3.5.AppImage";
    hash = "sha256-dZkKKdnMn1nS9bfQ89GJfW4w3iG455u1CwIBsLsiOHA=";
  };
  extraPkgs = pkgs: with pkgs; [];
}
