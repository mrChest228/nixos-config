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
            vars = import ./vars.nix;
            # my lib modules and packages, shared by every host (common/lib/*.nix, common/pkgs, ./pkgs)
            custom = import (common.path + /custom.nix) { inherit (nixpkgs-unstable) lib; inherit vars; com = common.path; cur = ./.; };
            mkLib = (pkgs: pkgs.lib.extend (final: prev: home-manager.lib // custom.lib final prev));
            lib = mkLib nixpkgs-unstable;

            pkgsConfig = (arch: {
                hostPlatform = arch;
                config = {
                    allowUnfree = true;
                };
            });
            # every overlay lives here, so pkgs.stable gets them too (lazy: unused packages cost nothing)
            mkPkgsOverlays = (pkgs: arch:
                (import pkgs (pkgsConfig arch)).appendOverlays [
                    (final: prev: { lib = mkLib pkgs; }) # Normal lib everywhere
                    custom.pkgs
                    (final: prev: {
                        # the same nix the determinate module installs; otherwise comma warns about eval-cores/lazy-trees
                        comma = prev.comma.override { nix = inputs.determinate.inputs.nix.packages.${arch}.default; };
                    })
                ]
            );
            mkPkgs = (arch: (mkPkgsOverlays nixpkgs-unstable arch).appendOverlays [ (final: prev: { stable = mkPkgsOverlays nixpkgs-stable arch; }) ]);

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
