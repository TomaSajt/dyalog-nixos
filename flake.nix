{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = rec {
        dyalog = pkgs.callPackage ./dyalog.nix { };
        ride = pkgs.callPackage ./ride.nix { };

        default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [ dyalog ride ]; };
      };

      overlay = _: prev: {
        dyalog = prev.callPackage ./dyalog.nix { };
        dyalog-ride = prev.callPackage ./ride.nix { };
      };
    };
}
