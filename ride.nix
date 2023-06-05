{ pkgs
, lib
, src
, rev
, fetchFromGitHub
, buildNpmPackage
, makeWrapper
, python3
, electron
, writeScript
, patchInterpreters ? true
, interpreters ? [ pkgs.dyalog ]
}:

let
  pname = "ride";
  version = "4.5";

  versionJSON = builtins.toJSON {
    versionInfo = {
      inherit version rev;
      date = "Unknown";
    };
  };

  interpretersJSON = builtins.toJSON (builtins.map
    (intr:
      {
        exe = "${intr}/bin/mapl";
        ver = lib.splitString "." intr.version;
        bits = 64;
        edition = "unicode";
        opt = "";
      }
    )
    interpreters);

in
buildNpmPackage {

  inherit pname version src;

  npmInstallFlags = [ "--omit=dev" ];

  # Skips the auto-downloaded electron binary
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmDepsHash = "sha256-mgkOTuspqoM4yZMr2u7f+0qSgzIMz033GXezuPA7rkQ=";
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper python3 ];

  # This is the replacement for the `mk` script in the source repo
  postInstall = ''
    cd $out/lib/node_modules/ride45

    mkdir $out/ride
    cp -r {src,lib,node_modules,D.png,favicon.*,*.html,main.js,package.json} $out/ride

    mkdir $out/ride/style
    cp -r style/{fonts,img,*.css} $out/ride/style

    cd $out/ride/node_modules
    rm -r {.bin,monaco-editor/{dev,esm,min-maps}}
    find . -type f -name '*.map' -exec rm -rf {} +
    find . -type d -name 'test' -exec rm -rf {} +

    rm -r $out/lib

    # Generate version-info
    mkdir $out/ride/_
    cd $out/ride/_
    echo 'D=${versionJSON}' > version.js
    echo ${version} > version

  
    # Call electron manually
    makeWrapper ${electron}/bin/electron $out/bin/ride --add-flags $out/ride

  '' + lib.optionalString patchInterpreters ''
    cd $out/ride/src
    echo 'module.exports = ${interpretersJSON}' > interpreters-nixpatch.js
    sed -i 's|interpreters = \[\]|interpreters = require("\.\/interpreters-nixpatch\.js")|' cn.js
  '';

  meta = with lib; {
    description = "Remote Integrated Development Environment for Dyalog APL";
    homepage = "https://github.com/Dyalog/ride";
    license = licenses.mit;
    maintainers = with maintainers; [ tomasajt ];
    platforms = [ "x86_64-linux" ];
  };
}

