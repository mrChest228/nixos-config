{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [ libs.import-tree ${self}/home-manager ];
    home = {
        username = vars.user;
        homeDirectory = "/home/${vars.user}";
        stateVersion = vars.systemVersion;
    };
}
