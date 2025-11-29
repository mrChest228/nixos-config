{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05"; # It must match the system varsion
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # Libs
        import-tree.url = "github:vic/import-tree";
    };
    outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, ... }:
        let
            host = "VICTUS";
            systemVersion = "25.05"; # System version. Do not change, if you don't read release notes. All version variables (nixpkgs-stable version, systemVersion) must be declared in flake.nix, not variables.nix
            vars = (import ./hosts/${host}/vars.nix) // { inherit host systemVersion; }; # Imports my variables and adds system version variable into vars
            pkgs = import nixpkgs {
                system = vars.arch;
                config = {
                    allowUnfree = true;
                    cuda.acceptLicense = true;
                    permittedInsecurePackages = []; # Clever people use this
                };
                overlays = [
                    (final: prev: {
                        stable = import nixpkgs-stable {
                            system = prev.system;
                            config = prev.config;
                        };
                    })
                ];
            };
        in {
            nixosConfigurations.${vars.host} = nixpkgs-stable.lib.nixosSystem {
                system = vars.arch;
                inherit pkgs;
                specialArgs = { inherit inputs vars self; }; # Pass vars into all imported modules
                modules = [
                    # { nixpkgs.pkgs = pkgs; }
                    ( inputs.import-tree ./hosts/${vars.host}/hardware )
                    ( inputs.import-tree ./hosts/${vars.host}/nixos )
                    ./nixos/config.nix
                ];
            };
            homeConfigurations.${vars.user} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = { inherit inputs vars self; }; # Pass vars into all imported modules
                modules = [
                    ( inputs.import-tree ./hosts/${vars.host}/home-manager )
                    ./home-manager/home.nix
                ];
            };
        };
}
