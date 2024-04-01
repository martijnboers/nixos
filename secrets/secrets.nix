let
  martijn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1ejrK2xtmts+pJj/2mPZHTj3HEXAznPKVJ/MhHa6PV martijn@ssh.thuis.plebian.nl";
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg7xqRr7ZqBTBsNvjBlqQXBE+9K2/5Qn4MT7VxwVTQj testbed@plebian.nl";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElgHjsOqLVDjObBrhg3gCQO7nesudsepiJxoTkBYCEl martijn@plebian.nl";
  hadouken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFaPlgRyXXEbbtzYgBPSkGWaY1vNvL/hV3CTJ1HOisv hadouken@plebian.nl";
  users = [martijn testbed hadouken laptop];
  hadoukens = [hadouken];
in {
  "hosts.age".publicKeys = users;
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
}
