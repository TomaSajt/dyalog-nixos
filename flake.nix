{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05-small;
  inputs.ride.url = github:Dyalog/ride;
  inputs.ride.flake = false;

  outputs = { self, nixpkgs, ride }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
    {
      overlay = final: prev: {
        dyalog = final.callPackage ./dyalog.nix { };
        ride = final.callPackage ./ride.nix { src = ride; rev = lock.nodes.ride.locked.rev; };
      };

      packages.${system} = rec {
        dyalog = pkgs.dyalog;
        ride = pkgs.ride;
        default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [ dyalog ride ]; };
      };
    };
}
