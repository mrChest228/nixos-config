{ config, lib, pkgs, vars, self, ... }: {
    nixpkgs.overlays = [(final: prev: {
        comma-with-db = prev.comma-with-db.override { nix = config.nix.package; };
    })];
    programs.nix-index-database.comma.enable = true;
}
