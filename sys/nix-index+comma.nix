{ config, lib, pkgs, vars, self, ... }: {
    nixpkgs.overlays = [(final: prev: {
        comma = prev.comma.override { nix = config.nix.package; };
    })];
    programs.nix-index-database.comma.enable = true;
}
