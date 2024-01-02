let
  martijn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElgHjsOqLVDjObBrhg3gCQO7nesudsepiJxoTkBYCEl martijn@plebian.nl";
  users = [martijn];
in {
  "hosts.age".publicKeys = users;
  "password.age".publicKeys = users;
  "smb.age".publicKeys = users;
}
