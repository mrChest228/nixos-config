{ config, lib, com, pkgs, vars, self, ... }: {
    imports = [
        com.options.ALL
        com.TOP_LEVEL
        com.scripts.config.conf."default.nix"
        com.scripts.config."update.nix"
        com.scripts.config."rebuild.nix"
        com.scripts.config."reconf.nix"
        com.scripts.config."gen.nix"
        com.scripts.config."clean.nix"
        ( lib.importTopLevel ./hardware )
        ( lib.importTopLevel ./. )
    ];
    
    users = {
        mutableUsers = false; # Disable passwd command and PAM crashing after the disk fully filled
        users = {
            "mrChest" = {
                isNormalUser = true;
                createHome = true;
                extraGroups = [ "wheel" "networkmanager" ];
                initialHashedPassword = ""; #TODO: hashed password file
            };
            root.hashedPassword = "!"; # I can't login to root user. Only @wheel
        };
    };
    services.getty.autologinUser = "mrChest";

    networking.hostName = vars.host;

    time.timeZone = vars.timeZone;
    
    i18n.defaultLocale = "en_US.UTF-8"; # Programs language
}

