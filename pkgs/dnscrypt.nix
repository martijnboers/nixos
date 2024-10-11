{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "dnscrypt";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "ameshkov";
    repo = "dnscrypt";
    rev = "v${version}";
    hash = "sha256-fk4J/5vpmPtZtP2qNAIotCotZK+W34cSi1m2ZzqeYH4=";
  };

  vendorHash = "sha256-KwVJ6Rlm0EHDITMCOEg29wqeu77M9vc00trKfPVzap8=";
  ldflags = [ "-s" "-w" ];

  checkPhase = ""; # Tests try to reach out to internet

  meta = {
    description = "DNSCrypt v2 protocol implementation + a command-line tool";
    homepage = "https://github.com/ameshkov/dnscrypt";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dnscrypt";
  };
}
