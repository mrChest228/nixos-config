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
                importTopLevel = dir: (inputs.import-tree.match "^[^/]+\\.nix$" dir);
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
                    inherit lib;
                    pkgs = mkPkgs vars.arch;
                    specialArgs = {
                        inherit self vars; # Push path to flake and vars into all imported modules
                    };
                    modules = [ ./hosts/${host}/config.nix ];
                })
            );
            mkHome = (vars: home-manager.lib.homeManagerConfiguration {
                inherit lib;
                pkgs = mkPkgs vars.arch;
                extraSpecialArgs = {
                    inherit self vars; # Push vars and path to flake into all imported modules
                };
                modules = [ (lib.importTopLevel ./hosts/${vars.host}/hm/${vars.user}) ];
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
