{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkgs,
}:
buildGoModule rec {
  pname = "smtp-gotify";
  version = "main";

  src = fetchFromGitHub {
    owner = "jreiml"; # This is a fork with updated dependencies. Besides this not bound to it
    repo = "smtp-gotify";
    rev = "4d0e477bf0180784ab4575d1462682208a351c1a";
    sha256 = "sha256-WFaJjdV4dlcsj44dVw6ETHLK0eA7Op5FJaCzK+94Kd8=";
  };

  vendorHash = "sha256-ZP6TSQa4f89F83JM4dJRwmrvLA4F1jx3cxOhqk13/74=";
  outputs = ["out"];
  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "A simple SMTP to Gotify bridge";
    license = licenses.mit;
  };
}
