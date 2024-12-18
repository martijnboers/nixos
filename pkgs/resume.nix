{
  stdenv,
  hugo,
}:
stdenv.mkDerivation {
  name = "resume-hugo";
  src = builtins.fetchGit {
    url = "git@github.com:martijnboers/resume.git";
    rev = "64b31c9a77987497a79ecf90abc843c2378c3c8a";
  };
  nativeBuildInputs = [hugo];
  phases = ["unpackPhase" "buildPhase"];
  buildPhase = ''
    hugo -s . -d "$out"
  '';
}
