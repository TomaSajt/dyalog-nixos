{ lib
, stdenv

, fetchurl
, dpkg
, autoPatchelfHook

, alsaLib
, atk
, cups
, glib
, gtk2
, nss_latest
, ncurses5
, pango
, unixODBC
, xorg
}:
let
  pname = "dyalog";
  version = "18.2.45405";

  shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

  src = fetchurl {
    url = "https://download.dyalog.com/download.php?file=${shortVersion}/linux_64_${version}_unicode.x86_64.deb";
    sha256 = "sha256-pA/WGTA6YvwG4MgqbiPBLKSKPtLGQM7BzK6Bmyz5pmM=";
  };
in
stdenv.mkDerivation {

  inherit pname version src;

  buildInputs = [
    autoPatchelfHook

    dpkg

    alsaLib
    ncurses5
    glib
    gtk2
    nss_latest
    unixODBC

    xorg.libXdamage
    xorg.libXScrnSaver
    xorg.libXtst
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/dyalog $out/bin
    mv ./opt/mdyalog/${shortVersion}/64/unicode/* $out/dyalog/

    ln -s $out/dyalog/dyalog $out/bin/dyalog
    ln -s $out/dyalog/mapl $out/bin/mapl
  '';

  meta = with lib; {
    description = "Dyalog APL";
    homepage = "https://www.dyalog.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ tomasajt ];
    platforms = [ "x86_64-linux" ];
  };
}
