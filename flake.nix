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
                # imports = get [ ... ]: file -> itself, dir -> its top-level .nix files, dir/... -> every .nix below it.
                # Names starting with _ or . are never picked up (a dir named explicitly is still read, only its _/. children are skipped),
                # so _config.nix / _home.nix stay entry points only.
                get = builtins.concatMap (p:
                    if !builtins.isPath p then throw "get: expected a path, got ${builtins.typeOf p}"
                    else if baseNameOf p == "..." then nixFiles true (dirOf p)
                    else if builtins.readFileType p == "directory" then nixFiles false p
                    else [ p ]
                );
            })));
            nixFiles = recurse: dir: let entries = builtins.readDir dir; in builtins.concatMap (name:
                let path = dir + "/${name}"; in # path + string keeps the path type
                if lib.hasPrefix "_" name || lib.hasPrefix "." name then []
                else if entries.${name} == "directory" then (if recurse then nixFiles true path else [])
                else if lib.hasSuffix ".nix" name then [ path ]
                else []
            ) (builtins.attrNames entries);
            # A <root>/pkgs/<name>.nix or package.nix directory is a package; directories without package.nix are recursive groups.
            # Names starting with _ or . are skipped at every level; packages replace prior values and groups merge into attrsets.
            # Host packages are applied after common, so a host package wins over a common package of the same name.
            pkgsFrom = (root: final: prev:
                let
                    dir = root + /pkgs;
                    packageArgs = {
                        inherit lib vars;
                        pkgs = final;
                        com = common.path;
                        cur = ./.;
                    };
                    visible = name: !lib.hasPrefix "_" name && !lib.hasPrefix "." name;
                    scan = directory: previous:
                        if !builtins.pathExists directory then {} else
                        let
                            entries = lib.filterAttrs (name: _: visible name) (builtins.readDir directory);
                            packageFiles = lib.filterAttrs (name: type:
                                (type == "regular" || type == "symlink") && lib.hasSuffix ".nix" name
                            ) entries;
                            packageDirs = lib.filterAttrs (_: type: type == "directory") entries;
                            filePackages = builtins.listToAttrs (builtins.map (file: {
                                name = lib.removeSuffix ".nix" file;
                                value = import (directory + "/${file}") packageArgs;
                            }) (builtins.attrNames packageFiles));
                            dirPackages = builtins.listToAttrs (builtins.map (name:
                                let
                                    path = directory + "/${name}";
                                    packagePath = path + /package.nix;
                                    old = if builtins.hasAttr name previous then builtins.getAttr name previous else {};
                                    additions = scan path (if builtins.isAttrs old then old else {});
                                in {
                                    inherit name;
                                    value = if builtins.pathExists packagePath then
                                        import packagePath packageArgs
                                    else if builtins.isAttrs old then old // additions
                                    else additions;
                                }
                            ) (builtins.attrNames packageDirs));
                            conflicts = builtins.filter (name: builtins.hasAttr name dirPackages) (builtins.attrNames filePackages);
                        in
                        if conflicts != [] then throw "${toString directory}: package/group name collision: ${lib.concatStringsSep ", " conflicts}"
                        else filePackages // dirPackages;
                in if builtins.pathExists dir then scan dir prev else {}
            );
            lib = mkLib nixpkgs-unstable;

            vars = import ./vars.nix;

            pkgsConfig = (arch: {
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
                (mkPkgsOverlays nixpkgs-unstable arch).appendOverlays [
                    (final: prev: {
                        stable = (mkPkgsOverlays nixpkgs-stable arch);
                    })
                    (pkgsFrom common.path)
                    (pkgsFrom ./.)
                ]
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
