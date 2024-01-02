let
  martijn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElgHjsOqLVDjObBrhg3gCQO7nesudsepiJxoTkBYCEl martijn@plebian.nl";
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg7xqRr7ZqBTBsNvjBlqQXBE+9K2/5Qn4MT7VxwVTQj testbed@plebian.nl";
  users = [martijn testbed];
in {
  "hosts.age".publicKeys = users;
  "password.age".publicKeys = users;
  "smb.age".publicKeys = users;
}
