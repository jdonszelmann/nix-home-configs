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

    t.url = "github:jdonszelmann/t-rs";
  };

  outputs = { self, home-manager, nixpkgs, flake-utils, nixvim, t }:
    let
      homeManagerModules = [ nixvim.homeManagerModules.nixvim ];

      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: prev: { custom = { t = t.packages.${system}.default; }; })
          ];
        };
      mkHomeConfiguration = root: args:
        home-manager.lib.homeManagerConfiguration ({
          modules = [ root ] ++ homeManagerModules ++ (args.modules or [ ]);
          pkgs = pkgsForSystem (args.system or "x86_64-linux");
        } // {
          inherit (args) extraSpecialArgs;
        });
    in flake-utils.lib.eachDefaultSystem (system: rec {
      formatter = legacyPackages.nixfmt;
      legacyPackages = pkgsForSystem system;
      pkgs = legacyPackages;
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (pkgs.writeShellScriptBin "fast-repl" ''
            source /etc/set-environment
            nix repl --file "${./.}/repl.nix" $@
          '')

          (pkgs.writeShellScriptBin "apply-home" ''
            nix run .#home-manager -- switch --flake .#$@
          '')

          (pkgs.writeShellScriptBin "apply" ''
            apply-home $(hostname -f)
          '')
        ];
      };
    }) // {

      homeConfigurations = {
        kili = mkHomeConfiguration (import ./hosts/kili/home.nix) {
          extraSpecialArgs = { };
        };
        ori = mkHomeConfiguration (import ./hosts/ori/home.nix) {
          extraSpecialArgs = { };
        };
      };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}
