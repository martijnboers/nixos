{
  stdenv,
  hugo,
  pkgs,
}:
stdenv.mkDerivation {
  name = "resume-hugo";
  src = builtins.fetchGit {
    url = "git@github.com:martijnboers/resume.git";
    rev = "8bd2de6ee2e9b2edc7e290dd33665d533a76661f";
  };
  nativeBuildInputs = [hugo];
  phases = ["unpackPhase" "buildPhase"];
  buildPhase = ''
    hugo -s . -d "$out"
  '';
}
