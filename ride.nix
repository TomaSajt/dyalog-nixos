{ lib
, stdenv

, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

, electron_13

, alsaLib
, gtk3
, mesa
, nss_latest
, xorg
}:

stdenv.mkDerivation rec {
  pname = "ride";
  version = "4.4.3732-1";

  shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

  # deal with '-1' suffix...
  cleanedVersion = builtins.replaceStrings [ "-1" ] [ "" ] version;

  src = fetchurl {
    url = "https://github.com/Dyalog/ride/releases/download/v${cleanedVersion}/ride-${version}_amd64.deb";
    sha256 = "sha256-kPqs/Xqk8cekQuMIbgIWOnUS+0twpTjtFSpkuP9Ynoo=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    dpkg
    makeWrapper

    alsaLib
    gtk3
    mesa
    nss_latest
    xorg.libxshmfence
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/ride $out/bin
    mv ./opt/ride-${shortVersion}/* $out/ride
    makeWrapper ${electron_13}/bin/electron $out/bin/ride \
        --add-flags $out/ride/resources/app  
  '';

}
