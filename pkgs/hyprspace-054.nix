{
  gcc14Stdenv,
  pkgs,
}:

gcc14Stdenv.mkDerivation {
  pname = "Hyprspace";
  version = "0.54.0-port";

  src = /home/martijn/Code/Hyprspace;

  nativeBuildInputs = pkgs.hyprland.nativeBuildInputs;
  buildInputs = [ pkgs.hyprland ] ++ pkgs.hyprland.buildInputs;
  dontUseCmakeConfigure = true;
  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mv $out/lib/Hyprspace.so $out/lib/libHyprspace.so
  '';

  meta = with pkgs.lib; {
    description = "Workspace overview plugin for Hyprland";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
