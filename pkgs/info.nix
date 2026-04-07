{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "boers-info";
  version = "1";
  src = fetchGit {
    url = "https://seed.boers.email/z2r9euHZW161kfQNxdF4apHddD3mm.git";
    rev = "1505f08958776961feef9fcd4826a615b7bcb39e";
  };
  installPhase = "cp -r . $out";
}
