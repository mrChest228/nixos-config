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
            # nixpkgs lib + home-manager lib + common/lib (get, getFiles, getTree)
            mkLib = (pkgs: pkgs.lib.extend (final: prev: home-manager.lib // (common.lib { lib = final; })));
            lib = mkLib nixpkgs-unstable;

            vars = import ./vars.nix;
            myPkgs = common.myPkgs { inherit lib vars; com = common.path; cur = ./.; };

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
                    # host packages come after common, so a host package wins over a common one of the same name
                    (myPkgs (common.path + /pkgs))
                    (myPkgs ./pkgs)
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
