{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "boers-blog";
  version = "1";
  src = fetchGit {
    url = "https://seed.boers.email/z3VzfnAfkQw6oLc5tSZyXmGE4RabW.git";
    rev = "8a3ee49419de5bd9c1d8aa02e12cdb47fe75aa0a";
    submodules = true;
  };
  nativeBuildInputs = [ pkgs.zola ];
  buildPhase = "zola build";
  installPhase = "cp -r public $out";
}
