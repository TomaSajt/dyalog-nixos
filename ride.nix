{ lib
, fetchFromGitHub
, buildNpmPackage
, makeWrapper
, python3
, electron
, dyalog
, withDyalog ? true
}:

let
  pname = "ride";
  version = "4.5.3770";
  rev = "246649aad81daadfa8ac7e0af7c0206e49b4e337";

  src = fetchFromGitHub {
    inherit rev;
    owner = "Dyalog";
    repo = pname;
    hash = "sha256-j3flZ1sKsYRkJ79yxmR4NKcOSf66bHsCXiupKhUAFcQ=";
  };

  versionJSON = builtins.toJSON {
    versionInfo = {
      inherit version rev;
      date = "2023-05-17 17:45:47 +0200";
    };
  };
in
buildNpmPackage {

  inherit pname version src;

  # Skips the auto-downloaded electron-chromedriver binary
  postPatch = "sed -i '/spectron/d' package.json";

  # Skips the auto-downloaded electron binary
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmDepsHash = "sha256-mgkOTuspqoM4yZMr2u7f+0qSgzIMz033GXezuPA7rkQ=";
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper python3 ];

  # This is the replacement for the `mk` script in the source repo
  postInstall = ''
    cd $out/lib/node_modules/ride45

    mkdir $out/app
    cp -r {src,lib,node_modules,D.png,favicon.*,*.html,main.js,package.json} $out/app

    mkdir $out/app/style
    cp -r style/{fonts,img,*.css} $out/app/style

    rm -r $out/lib

    # Generate version-info
    mkdir $out/app/_
    echo 'D=${versionJSON}' > $out/app/_/version.js
    echo ${version} > $out/app/_/version

  
    # Call electron manually
    makeWrapper ${electron}/bin/electron $out/bin/ride \
            --add-flags $out/app
  '' + lib.optionalString withDyalog ''
    sed -i 's|const interpreters = \[\]|const interpreters = \[{exe:"${dyalog}/bin/dyalog",ver:\[18,2\],bits:64,edition:"unicode",opt:""}\]|' $out/app/src/cn.js
  '';

  meta = with lib; {
    description = "Remote Integrated Development Environment for Dyalog APL";
    homepage = "https://github.com/Dyalog/ride";
    license = licenses.mit;
    maintainers = with maintainers; [ tomasajt ];
    platforms = [ "x86_64-linux" ];
  };
}

