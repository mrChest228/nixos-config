{ config, lib, pkgs, vars, com, cur, ... }: {
    imports = [
        (lib.importTopLevel (com + "/hm/root")) # root imports only hm/root: modules it evaluates must stay root-owned
        ( lib.importTopLevel (cur + "/hm/root") )  # host/hm/root
    ];
    home = {
        username = vars.user;
        homeDirectory = "/root";
        stateVersion = "26.05"; # It manages programs configuring rules. Use the latest version for new settings
        enableNixpkgsReleaseCheck = false; # I use custom pkgs, they're mostly pkgs.unstable, like the unstable HM, but it doesn't know that
        sessionVariables = {
        };
    };
}
