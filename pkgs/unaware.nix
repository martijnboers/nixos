{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "unaware";
  version = "master";

  src = fetchFromGitHub {
    owner = "martijnboers";
    repo = "unaware";
    rev = "master";
    hash = "sha256-QcegXl+VJtuBYIFoOLUao/t3xd6aouwvLSFm54wwvvU=";
  };

  vendorHash = "sha256-IWS8HVsV+KJzJpjCn0+AkeKZ4i4KoNIQpjLTTF6aReU=";

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/unaware
  '';

  meta = with lib; {
    description = "Mask PII-data offline";
    homepage = "https://github.com/martijnboers/unaware";
    license = licenses.mpl20;
    mainProgram = "unaware";
  };
}
