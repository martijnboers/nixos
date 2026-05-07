{
  lib,
  buildGoModule,
  pkgs,
}:

buildGoModule {
  pname = "unaware";
  version = "1.3";

  src = pkgs.fetchFromRadicle {
    seed = "seed.boers.email";
    repo = "z3bTedCQLQRkCdAmKKZTMSBimNp4J";
    rev = "5e1c263bb0b3027d24124e0679af4541e99e9ac4";
    hash = "sha256-kdjGiY1EjoleOxf5orNebrWIYR3zDW2lsh1kds7+JOU=";
  };

  vendorHash = "sha256-KDAerpxeKy5EfL87HZBeiqzm4QSlkv68nKK6FIwkVaI=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Mask PII-data offline";
    homepage = "https://github.com/noisesfromspace/unaware";
    license = licenses.mpl20;
    mainProgram = "unaware";
  };
}
