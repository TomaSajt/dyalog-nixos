{ lib
, stdenv

, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

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

  nativeBuildInputs = [ autoPatchelfHook makeWrapper dpkg ];

  buildInputs = [
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

    makeWrapper $out/dyalog/dyalog $out/bin/dyalog \
            --set SESSION_FILE $out/dyalog/default.dse
    makeWrapper $out/dyalog/mapl $out/bin/mapl \
            --set SESSION_FILE $out/dyalog/default.dse
  '';

  meta = with lib; {
    description = "Dyalog APL";
    homepage = "https://www.dyalog.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ tomasajt ];
    platforms = [ "x86_64-linux" ];
  };
}
