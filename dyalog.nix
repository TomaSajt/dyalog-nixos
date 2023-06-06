{ lib
, stdenv

, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

, glib
, ncurses5
, unixODBC
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
    ncurses5
    glib
    unixODBC
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/dyalog $out/bin $out/share/applications
    mv ./opt/mdyalog/${shortVersion}/64/unicode/* $out/dyalog
    cd $out/dyalog 

    # Remove RIDE files and other stuff that's probably not going to be used
    rm -r {RIDEapp,help,swiftshader,locales,xfsrc,scriptbin}
    rm {cef*.pak,chrome-sandbox,libEGL.so,libGLESv2.so,libcef.so,v8_context_snapshot.bin,snapshot_blob.bin,natives_blob.bin,icudtl.dat,Dyalog.Net.Bridge*,magic,lib/htmlrenderer.so}
    
    mv dyalog.desktop $out/share/applications

    makeWrapper $out/dyalog/dyalog $out/bin/dyalog \
        --set SESSION_FILE $out/dyalog/default.dse \
        --add-flags APLKEYS=$out/dyalog/aplkeys \
        --add-flags APLTRANS=$out/dyalog/apltrans
  '';

}
