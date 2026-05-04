{ config, lib, pkgs, vars, self, ... }:
{
    imports = [
        ( lib.importTopLevel (self + /sys) )
        ( lib.importTopLevel ./hardware )
        ( lib.importTopLevel ./. )
    ];
    
    users.users."mrchest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "";
    };
    # services.getty.autologinUser = vars.user;

    networking.hostName = vars.host;

    time.timeZone = vars.timeZone;
    
    i18n.defaultLocale = "en_US.UTF-8"; # Programs language
}

