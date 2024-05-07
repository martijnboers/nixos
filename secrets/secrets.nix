let
  glassdoor = builtins.readFile ../nixos/keys/glassdoor.pub;
  laptop = builtins.readFile ../nixos/keys/laptop.pub;
  hadouken = builtins.readFile ../nixos/keys/hadouken.pub;
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg7xqRr7ZqBTBsNvjBlqQXBE+9K2/5Qn4MT7VxwVTQj testbed@plebian.nl";
  users = [glassdoor testbed hadouken laptop];
  hadoukens = [hadouken];
in {
  "password.age".publicKeys = users;
  "smb.age".publicKeys = users;
  "openai.age".publicKeys = users;
  "borg.age".publicKeys = users;

  "nextcloud.age".publicKeys = hadoukens;
  "acl.age".publicKeys = hadoukens;
  "pgrok.age".publicKeys = hadoukens;
  "keycloak.age".publicKeys = hadoukens;
  "caddy.age".publicKeys = hadoukens;
  "headscale.age".publicKeys = hadoukens;
  "geoip.age".publicKeys = hadoukens;
  "immich.age".publicKeys = hadoukens;
  "adguard.age".publicKeys = hadoukens;
}
