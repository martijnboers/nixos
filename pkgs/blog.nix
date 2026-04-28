{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "boers-blog";
  version = "1";
  src = fetchGit {
    url = "https://seed.boers.email/z3VzfnAfkQw6oLc5tSZyXmGE4RabW.git";
    rev = "96d6b88715816c5608f3fe9e3c57f35bf38fa7c4";
    submodules = true;
  };
  nativeBuildInputs = [ pkgs.zola ];
  buildPhase = "zola build";
  installPhase = "cp -r public $out";
}
