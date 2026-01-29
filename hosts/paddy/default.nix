{
  lib,
  config,
  pkgs,
  ...
}:
let
  intel-vision-driver = config.boot.kernelPackages.callPackage (
    {
      stdenv,
      lib,
      fetchFromGitHub,
      kernel,
    }:
    stdenv.mkDerivation {
      pname = "intel-vision-drivers";
      version = "master";

      src = fetchFromGitHub {
        owner = "intel";
        repo = "vision-drivers";
        rev = "master";
        hash = "sha256-zOvCZKGwOGT9kcJiefzx/duHqR0V8PYhNbqsMHkH1r4=";
      };

      hardeningDisable = [
        "pic"
        "format"
      ];
      nativeBuildInputs = kernel.moduleBuildDependencies;

      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
        cp intel_cvs.ko $out/lib/modules/${kernel.modDirVersion}/extra/
        runHook postInstall
      '';

      meta = with lib; {
        description = "Intel Vision Drivers (CVS)";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    }
  ) { };
in
{
  networking.hostName = "paddy";
  hosts.hyprland.enable = true;
  hosts.secureboot.enable = true;

  boot.extraModulePackages = [ intel-vision-driver ];
  boot.kernelModules = [ "intel_cvs" ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hosts.borg = {
    enable = true;
    repository = "ssh://nkhm1dhr@nkhm1dhr.repo.borgbase.com/./repo";
    identityPath = "/home/martijn/.ssh/id_ed25519";
    paths = [ "/home/martijn" ];
    exclude = [
      ".cache"
      "*/cache2" # librewolf
      "*/Cache"
      ".wine"
      ".config/Slack/logs"
      ".config/Code/CachedData"
      ".container-diff"
      ".npm/_cacache"
      "*/node_modules"
      "*/_build"
      "*/venv"
      "*/.venv"
      "/home/*/.local"
      "/home/*/Downloads"
      "/home/*/Data"
      "/home/*/.ssh"
    ];
  };

  users.users.martijn = {
    hashedPasswordFile = lib.mkForce config.age.secrets.password-laptop.path;
  };

  hosts.tailscale.enable = true;
  hosts.yubikey = {
    enable = true;
    autolock = true;
  };
}
