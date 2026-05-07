{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "boers-info";
  version = "1";
  src = pkgs.fetchFromRadicle {
    seed = "seed.boers.email";
    repo = "z2r9euHZW161kfQNxdF4apHddD3mm";
    rev = "490bb24bef80f8e2550071dcbeb39bde837ab50b";
    hash = "sha256-sXXg4z6JjsR+uTuCGEMOht0k+xuwziE66wFvaG/4aS8=";
  };
  installPhase = "cp -r . $out";
}
