let
  glassdoor = builtins.readFile ../nixos/keys/glassdoor.pub;
  hadouken = builtins.readFile ../nixos/keys/hadouken.pub;
  shoryuken = builtins.readFile ../nixos/keys/shoryuken.pub;
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg7xqRr7ZqBTBsNvjBlqQXBE+9K2/5Qn4MT7VxwVTQj testbed@plebian.nl";
  basic = [glassdoor testbed hadouken shoryuken];
  hadoukens = [glassdoor hadouken];
  shoryukens = [glassdoor shoryuken];
in {
  "password.age".publicKeys = basic;
  "smb.age".publicKeys = basic;
  "openai.age".publicKeys = basic;
  "borg.age".publicKeys = basic;

  "keycloak.age".publicKeys = shoryukens;
  "headscale.age".publicKeys = shoryukens;

  "nextcloud.age".publicKeys = hadoukens;
  "acl.age".publicKeys = hadoukens;
  "pgrok.age".publicKeys = hadoukens;
  "caddy.age".publicKeys = hadoukens;
  "geoip.age".publicKeys = hadoukens;
  "immich.age".publicKeys = hadoukens;
  "adguard.age".publicKeys = hadoukens;
  "fedifetcher.age".publicKeys = hadoukens;
  "email.age".publicKeys = hadoukens;
}
