{ config, lib, pkgs, vars, self, ... }: {
    programs.nix-index-database.comma.enable = true;
}
