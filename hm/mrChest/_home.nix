{ config, lib, com, pkgs, vars, self, ... }: {
    imports = [
        com.topLevel
        com.${vars.user}.topLevel
        ( lib.importTopLevel ../. ) # host/hm
        ( lib.importTopLevel ./. )  # host/hm/user
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
