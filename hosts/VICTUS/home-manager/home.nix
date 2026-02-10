{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [ ( libs.import-tree (self + /home-manager) ) ];
    home = {
        username = vars.user;
        homeDirectory = "/home/${vars.user}";
        stateVersion = vars.systemVersion;
        enableNixpkgsReleaseCheck = false; # I use custom pkgs, they're mostly pkgs.unstable, like the unstable HM, but it doesn't know that 
        sessionVariables = {
            FLAKE = vars.configPath;
        };
    };
}
