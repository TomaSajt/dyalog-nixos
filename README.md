# Dyalog APL and RIDE Editor

A fork of https://github.com/markus1189/dyalog-nixos

This repository contains a `nix` definition to install dyalog APL
(https://www.dyalog.com/) and RIDE (https://github.com/Dyalog/ride).


## Howto

Run `nix-shell` in the directory, providing you with both `dyalog` and
`ride` in your path.  Afterwards you can open RIDE and tell it to
launch `dyalog` (available in PATH).

With flakes, you can run `nix shell github:TomaSajt/dyalog-nixos#{dyalog,ride}`

## Troubleshooting

If you get 404 for dyalog or ride download:
  - dyalog: find new version at https://www.dyalog.com/download-zone.htm?p=download
  - ride: find new version at  https://github.com/Dyalog/ride/releases

and update the corresponding files.

## Using the flake

You can run dyalog and RIDE using the nix flake like this:

```
nix shell github:TomaSajt/dyalog-nixos
```

## Links:

You can find documentation on `dyalog` and `ride` here: https://www.dyalog.com/documentation.htm

## And the most important thing

Happy Hacking!
