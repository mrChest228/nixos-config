{
    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11"; # It must match the systemVersion
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            # inputs.nixpkgs.follows = "nixpkgs";
        };
        # Libs
        import-tree.url = "github:vic/import-tree";
    };
    outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
        let
            host = "VICTUS";
            systemVersion = "25.11"; # System version. Do not change, if you don't read release notes. All version variables (nixpkgs-stable version, systemVersion) must be declared in flake.nix, not variables.nix
            vars = (import ./hosts/${host}/vars.nix) // { inherit host systemVersion; }; # Imports my variables and adds system version variable into vars
            pkgsConfig = {
                system = vars.arch;
                hostPlatform = vars.arch;
                config = {
                    allowUnfree = true;
                    cuda.acceptLicense = true;
                    permittedInsecurePackages = []; # Clever people use this
                };
            };
            pkgs = (import nixpkgs-stable pkgsConfig).appendOverlays [(final: prev: {
                unstable = import nixpkgs-unstable pkgsConfig;
            })];
        in {
            nixosConfigurations.${vars.host} = nixpkgs-stable.lib.nixosSystem {
                inherit pkgs;
                specialArgs = {
                    libs = inputs;
                    inherit vars self; # Pass vars and path to flake into all imported modules
                };
                modules = [
                    # { nixpkgs.pkgs = pkgs; }
                    # { nixpkgs.hostPlatform = vars.arch; }
                    ( inputs.import-tree ./hosts/${vars.host}/hardware )
                    ( inputs.import-tree ./hosts/${vars.host}/nixos )
                ];
            };
            homeConfigurations.${vars.user} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                    libs = inputs;
                    inherit vars self; # Pass vars and path to flake into all imported modules
                };
                modules = [
                    ( inputs.import-tree ./hosts/${vars.host}/home-manager )
                ];
            };
        };
}
