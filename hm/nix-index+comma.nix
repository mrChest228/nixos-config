{ config, lib, pkgs, vars, self, ... }: {
    programs = {
        nix-index-database.comma.enable = true;
        # nix-index.enable is already on
        nix-index.enableNushellIntegration = true;
    };
}
