{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "boers-info";
  version = "1";
  src = fetchGit {
    url = "https://seed.boers.email/z2r9euHZW161kfQNxdF4apHddD3mm.git";
    rev = "490bb24bef80f8e2550071dcbeb39bde837ab50b";
  };
  installPhase = "cp -r . $out";
}
