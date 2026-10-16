{ config, lib, pkgs, vars, com, cur, ... }: {
    imports = [
        (lib.importTopLevel (com + "/hm"))
        (com + "/hm/root/nushell.nix") # shared shell setup moved to hm/root, users may import it (reading root's files is safe)
        (com + "/hm/root/git.nix")
        (lib.importTopLevel (com + "/hm/${vars.user}"))
        ( lib.importTopLevel (cur + "/hm") ) # host/hm
        ( lib.importTopLevel (cur + "/hm/${vars.user}") )  # host/hm/user
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
