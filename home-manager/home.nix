{ config, lib, inputs, pkgs, vars, self, ... }:
{
    imports = [ inputs.import-tree ./modules ];
    home = {
        username = vars.user;
        homeDirectory = "/home/${vars.user}";
        stateVersion = vars.systemVersion;
    };
}
