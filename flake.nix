{
    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11"; # It must match the systemVersion
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        # Fast nix-eval
        determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
        # Libs
        import-tree.url = "github:vic/import-tree";
    };
    outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
        let
            host = "VICTUS";
            vars = (import ./hosts/${host}/vars.nix) // { inherit host; }; # Imports my variables and adds host variable into vars
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
                modules = [ ./hosts/${vars.host}/config.nix ];
            };
            homeConfigurations.${vars.user} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                    libs = inputs;
                    inherit vars self; # Pass vars and path to flake into all imported modules
                };
                modules = [ ./hosts/${vars.host}/home.nix ];
            };
        };
}
