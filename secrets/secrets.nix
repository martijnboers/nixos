let
  martijn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElgHjsOqLVDjObBrhg3gCQO7nesudsepiJxoTkBYCEl martijn@plebian.nl";
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg7xqRr7ZqBTBsNvjBlqQXBE+9K2/5Qn4MT7VxwVTQj testbed@plebian.nl";
  hadouken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFaPlgRyXXEbbtzYgBPSkGWaY1vNvL/hV3CTJ1HOisv hadouken@plebian.nl";
  users = [martijn testbed hadouken];
  hadouken = [hadouken];
in {
  "hosts.age".publicKeys = users;
  "password.age".publicKeys = users;
  "smb.age".publicKeys = users;
  "openai.age".publicKeys = users;
  "nextcloud.age".publicKeys = hadouken;
  "borg.age".publicKeys = users;
  "pgrok.age".publicKeys = hadouken;
  "keycloak.age".publicKeys = hadouken;
  "caddy.age".publicKeys = hadouken;
  "headscale.age".publicKeys = hadouken;
}
