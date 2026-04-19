{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [
        ( libs.import-tree (self + /home-manager) )
        ( libs.import-tree ./home-manager )
    ];
    home = {
        username = vars.user;
        homeDirectory = "/home/${vars.user}";
        stateVersion = "26.05"; # It manages programs configuring rules. Use the latest version for new settings
        enableNixpkgsReleaseCheck = false; # I use custom pkgs, they're mostly pkgs.unstable, like the unstable HM, but it doesn't know that 
        sessionVariables = {
        };
    };
}
