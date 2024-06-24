{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, home-manager, nixpkgs, flake-utils, nixvim }:
    let
      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHomeConfiguration = args:
        home-manager.lib.homeManagerConfiguration (rec {
          modules = [ (import ./home.nix) nixvim.homeManagerModules.nixvim ]
            ++ (args.modules or [ ]);
          pkgs = pkgsForSystem (args.system or "x86_64-linux");
        } // {
          inherit (args) extraSpecialArgs;
        });

    in flake-utils.lib.eachDefaultSystem (system: rec {
      formatter = legacyPackages.nixfmt;
      legacyPackages = pkgsForSystem system;
    }) // {
      # non-system suffixed items should go here
      nixosModules.home = import ./home.nix; # attr set or list

      homeConfigurations.kili = mkHomeConfiguration { extraSpecialArgs = { }; };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}
