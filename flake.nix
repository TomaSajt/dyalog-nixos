{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };

    in
    {
      packages.${system} = rec {
        dyalog = pkgs.dyalog;
        ride = pkgs.ride;
        default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [ dyalog ride ]; };
      };

      overlay = final: prev: {
        dyalog = final.callPackage ./dyalog.nix { };
        ride = final.callPackage ./ride.nix { };
      };
    };
}
