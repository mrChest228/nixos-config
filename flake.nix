{
    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        # Fast nix-eval
        determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
        # Niri
        niri = {
            url = "github:sodiboo/niri-flake";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        # Libs
        import-tree.url = "github:vic/import-tree";
        nix-index-database = { # Needs for nix-index and comma fast search/index
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
    };
    outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
        let
            mkLib = (pkgs: pkgs.lib.extend (final: prev: (home-manager.lib // {
                importTree = inputs.import-tree;
                importTopLevel = dir: (inputs.import-tree.match "^/[^/]+\\.nix$" dir);
            })));
            lib = mkLib nixpkgs-unstable;

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
            mkPkgsOverlays = (pkgs: arch:
                (import pkgs (pkgsConfig arch)).appendOverlays [
                    (final: prev: { lib = mkLib pkgs; }) # Normal lib everywhere
                    # (final: prev: { comma-with-db = prev.comma-with-db.override { nix = final.nix } }) # Removes warning "unknown setting 'eval-cores' and 'lazy-trees'" from determinate nix config
                ]
            );
            mkPkgs = (arch:
                (mkPkgsOverlays nixpkgs-unstable arch).appendOverlays [(final: prev: {
                    stable = (mkPkgsOverlays nixpkgs-stable arch);
                })]
            );

            mkSys = (host: nixpkgs-unstable.lib.nixosSystem (
                let
                    vars = (import ./hosts/${host}/vars.nix) // { inherit host; };
                in {
                    pkgs = mkPkgs vars.arch;
                    specialArgs = {
                        inherit lib vars self; # self is a path to the flake
                    };
                    modules = [
                        inputs.determinate.nixosModules.default # To make Determinate.nix works
                        ./hosts/${host}/sys/_config.nix         # _ needs to protect the import with import-tree
                    ];
                })
            );
            mkHome = (vars: home-manager.lib.homeManagerConfiguration {
                pkgs = mkPkgs vars.arch;
                extraSpecialArgs = {
                    inherit lib vars self; # self is a path to the flake
                };
                modules = [
                    inputs.nix-index-database.homeModules.nix-index
                    inputs.niri.homeModules.niri
                    ./hosts/${vars.host}/hm/${vars.user}/_home.nix # _ needs to protect the import with import-tree
                ];
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
