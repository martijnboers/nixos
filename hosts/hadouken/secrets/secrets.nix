let
  hadouken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFaPlgRyXXEbbtzYgBPSkGWaY1vNvL/hV3CTJ1HOisv hadouken@plebian.nl";
  hadoukens = [hadouken];
in {
  "nextcloud.age".publicKeys = hadoukens;
  "acl.age".publicKeys = hadoukens;
  "pgrok.age".publicKeys = hadoukens;
  "keycloak.age".publicKeys = hadoukens;
  "caddy.age".publicKeys = hadoukens;
  "headscale.age".publicKeys = hadoukens;
}
