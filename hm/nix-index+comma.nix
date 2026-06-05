{ config, lib, pkgs, vars, self, ... }: {
    nixpkgs.overlays = [(final: prev: {
        comma-with-db = prev.comma-with-db.override { nix = null; }; # Don't use HM nix package. Use only system determinate version. Prevent warning "unknown settings 'eval-cores' and 'lazy-trees'" from determinate nix config
    })];
    programs = {
        nix-index-database.comma.enable = true;
        # nix-index.enable is already on
        nix-index.enableNushellIntegration = true;
    };
}
