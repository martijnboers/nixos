{
  gcc14Stdenv,
  pkgs,
}:

gcc14Stdenv.mkDerivation {
  pname = "scooter";
  version = "0.1.0";

  src = /home/martijn/Code/scooter;

  nativeBuildInputs = pkgs.hyprland.nativeBuildInputs;
  buildInputs = [ pkgs.hyprland ] ++ pkgs.hyprland.buildInputs;
  dontUseCmakeConfigure = true;

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mkdir -p $out/lib
    mv $out/lib/scooter.so $out/lib/libscooter.so || mv scooter.so $out/lib/libscooter.so
  '';

  meta = with pkgs.lib; {
    description = "Minimal workspace overview plugin for Hyprland";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
