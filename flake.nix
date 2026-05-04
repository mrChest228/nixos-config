{
    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
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
            lib = nixpkgs-unstable.lib // { # Standart lib + my own functions
                importTree = inputs.import-tree;
                importTopLevel = dir: (inputs.import-tree.match "^/[^/]+\\.nix$" dir);
            };
            hosts = builtins.attrNames ( # Get only dirs from ./hosts
                lib.filterAttrs
                    (name: type: type == "directory")
                    (builtins.readDir ./hosts)
            );

            pkgsConfig = (arch: {
                system = arch;
                hostPlatform = arch;
                config = {
                    allowUnfree = true;
                    cuda.acceptLicense = true;
                    permittedInsecurePackages = []; # Clever people use this
                };
            });
            mkPkgs = (arch:
                (import nixpkgs-stable (pkgsConfig arch)).appendOverlays [(final: prev: {
                    unstable = import nixpkgs-unstable (pkgsConfig arch);
                })]
            );

            mkSys = (host: nixpkgs-stable.lib.nixosSystem (
                let
                    vars = (import ./hosts/${host}/vars.nix) // { inherit host; };
                in {
                    pkgs = mkPkgs vars.arch;
                    specialArgs = {
                        inherit lib vars self; # self is a path to the flake
                    };
                    modules = [
                        inputs.determinate.nixosModules.default # To make Determinate.nix works
                        ./hosts/${host}/sys/_config.nix         # _ so as not to import with import-tree
                    ];
                })
            );
            mkHome = (vars: home-manager.lib.homeManagerConfiguration {
                pkgs = mkPkgs vars.arch;
                extraSpecialArgs = {
                    inherit lib vars self; # self is a path to the flake
                };
                modules = [ ./hosts/${vars.host}/hm/${vars.user}/home.nix ]; # _ so as not to import with import-tree
            });
        in {
            nixosConfigurations = lib.genAttrs hosts mkSys;
            homeConfigurations = lib.mergeAttrsList (builtins.concatMap (host: # Merge list of lists of dictionaries into a simple list of dicts and then merge them into a single dict
                let
                    vars = (import ./hosts/${host}/vars.nix) // { inherit host; };
                in
                    builtins.map (user: {
                        "${user}@${host}" = (mkHome (vars // { inherit user; }));
                    }) vars.users # Return a list of dicts
            ) hosts);
        };
}
