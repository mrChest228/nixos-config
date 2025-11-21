{ config, inputs, lib, pkgs, vars, ... }:
{
    imports = [
        ( inputs.import-tree ./modules )
        ( inputs.import-tree /etc/nixos/hosts/${vars.host}/home-manager )
    ];
    home = {
        username = vars.user;
        homeDirectory = "/home/${vars.user}";
        stateVersion = vars.systemVersion;
    };
}
