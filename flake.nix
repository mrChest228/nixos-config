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
        # niri = {
        #     url = "github:sodiboo/niri-flake";
        #     inputs.nixpkgs.follows = "nixpkgs-unstable";
        # };
        # Libs
        import-tree.url = "github:vic/import-tree";
        nix-index-database = { # Needs for nix-index and comma fast search/index
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        # All my common modules
        common.url = "git+file:///etc/nixos/common";
    };
    outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, common, ... }:
        let
            mkLib = (pkgs: pkgs.lib.extend (final: prev: (home-manager.lib // {
                importTree = inputs.import-tree;
                importTopLevel = dir: (inputs.import-tree.match "^/[^/]+\\.nix$" dir);
            })));
            lib = mkLib nixpkgs-unstable;

            vars = import ./vars.nix;

            pkgsConfig = (arch: {
                system = arch;
                hostPlatform = arch;
                config = {
                    allowUnfree = true;
                };
            });
            mkPkgsOverlays = (pkgs: arch:
                (import pkgs (pkgsConfig arch)).appendOverlays [
                    (final: prev: { lib = mkLib pkgs; }) # Normal lib everywhere
                    
                ]
            );
            mkPkgs = (arch:
                (mkPkgsOverlays nixpkgs-unstable arch).appendOverlays [(final: prev: {
                    stable = (mkPkgsOverlays nixpkgs-stable arch);
                })]
            );

            mkSys = (vars: nixpkgs-unstable.lib.nixosSystem {
                pkgs = mkPkgs vars.arch;
                specialArgs = {
                    inherit lib vars self; # self is a path to the flake
                    com = common.sys;
                };
                modules = [
                    inputs.determinate.nixosModules.default
                    inputs.nix-index-database.nixosModules.nix-index
                    ./sys/_config.nix         # _ needs to protect the import with import-tree
                ];
            });
            mkHome = (vars: home-manager.lib.homeManagerConfiguration {
                pkgs = mkPkgs vars.arch;
                extraSpecialArgs = {
                    inherit lib vars self; # self is a path to the flake
                    com = common.hm;
                };
                modules = [
                    # inputs.niri.homeModules.niri
                    ./hm/${vars.user}/_home.nix # _ needs to protect the import with import-tree
                ];
            });
        in {
            nixosConfigurations.${vars.host} = mkSys vars;
            homeConfigurations = lib.mergeAttrsList (builtins.map (user: {
                "${user}@${vars.host}" = (mkHome (vars // { inherit user; }));
            }) vars.users);
        };
}
