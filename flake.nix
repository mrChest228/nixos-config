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
                # imports = get [ ... ]: file -> itself, dir -> its top-level .nix files, dir/... -> every .nix below it.
                # Names starting with _ are never picked up, so _config.nix / _home.nix stay entry points only.
                get = builtins.concatMap (p:
                    if !builtins.isPath p then throw "get: expected a path, got ${builtins.typeOf p}"
                    else if baseNameOf p == "..." then nixFiles true (dirOf p)
                    else if builtins.readFileType p == "directory" then nixFiles false p
                    else [ p ]
                );
            })));
            nixFiles = recurse: dir: let entries = builtins.readDir dir; in builtins.concatMap (name:
                let path = dir + "/${name}"; in # path + string keeps the path type
                if lib.hasPrefix "_" name then []
                else if entries.${name} == "directory" then (if recurse then nixFiles true path else [])
                else if lib.hasSuffix ".nix" name then [ path ]
                else []
            ) (builtins.attrNames entries);
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

            mkHome = (vars: home-manager.lib.homeManagerConfiguration {
                pkgs = mkPkgs vars.arch;
                extraSpecialArgs = {
                    inherit lib vars;
                    inherit (lib) get;
                    com = common.path; # path to the common flake
                    cur = ./.;         # path to this flake
                };
                modules = [
                    # inputs.niri.homeModules.niri
                    ./hm/${vars.user}/_home.nix # _ hides it from get
                ];
            });
        in {
            nixosConfigurations.${vars.host} = nixpkgs-unstable.lib.nixosSystem {
                pkgs = mkPkgs vars.arch;
                specialArgs = {
                    inherit lib vars;
                    inherit (lib) get;
                    com = common.path; # path to the common flake
                    cur = ./.;         # path to this flake
                };
                modules = [
                    inputs.determinate.nixosModules.default
                    inputs.nix-index-database.nixosModules.nix-index
                    ./sys/_config.nix         # _ hides it from get
                ];
            };
            homeConfigurations = lib.mergeAttrsList (builtins.map (user: {
                "${user}@${vars.host}" = (mkHome (vars // { inherit user; }));
            }) ([ "root" ] ++ vars.users));
        };
}
