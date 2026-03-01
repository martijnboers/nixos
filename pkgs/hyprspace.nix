{
  gcc14Stdenv,
  fetchFromGitHub,
  pkgs,
}:
# https://github.com/KZDKM/Hyprspace/blob/main/flake.nix
gcc14Stdenv.mkDerivation rec {
  pname = "Hyprspace";
  version = "bcd969224ffeb6266c6618c192949461135eef38";

  # version = "support_hyprland_0_54_0";
  # src = /home/martijn/Code/Hyprspace;

  src = fetchFromGitHub {
    owner = "KZDKM";
    repo = "Hyprspace";
    rev = "${version}";
    hash = "sha256-Gge7LY1lrPc2knDnyw8GBQ2sxRPzM7W2T6jNG1HY5bA=";
  };

  nativeBuildInputs = pkgs.hyprland.nativeBuildInputs;
  buildInputs = [ pkgs.hyprland ] ++ pkgs.hyprland.buildInputs;
  dontUseCmakeConfigure = true;

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mv $out/lib/Hyprspace.so $out/lib/libHyprspace.so
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/KZDKM/Hyprspace";
    description = "Workspace overview plugin for Hyprland";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
