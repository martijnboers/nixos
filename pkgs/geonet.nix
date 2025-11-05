{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:

rustPlatform.buildRustPackage rec {
  pname = "geonet-rs";
  version = "0.4.4";

  src = fetchFromGitLab {
    owner = "shodan-public";
    repo = "geonet-rs";
    rev = "${version}";
    hash = "sha256-lEvpRjSCkb7dE8XXUI4RqZcsB3zh6vr1jyK+K6PUjNA=";
  };

  cargoHash = "sha256-o3Q9t/YSj6+S9obqOJXq9RCGdNfisUGoz/Lyej/n04I=";
  doCheck = false;

  meta = with lib; {
    description = "Network tools that run from multiple geographic locations using the GeoNet API";
    longDescription = ''
      Geographic network tools that provide:
      - geodns: lookup DNS records for a hostname from multiple locations
      - geoping: ping an IP/hostname from multiple locations around the world
    '';
    homepage = "https://gitlab.com/shodan-public/geonet-rs";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "geoping";
  };
}
