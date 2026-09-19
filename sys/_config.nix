{ config, lib, pkgs, vars, self, ... }: {
    imports = [
        ( lib.importTree (self + /sys/options) )
        ( lib.importTopLevel (self + /sys) )
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

