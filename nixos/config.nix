{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [ ( libs.import-tree ./modules ) ];
    
    users.users.${vars.user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "";
    };
    # services.getty.autologinUser = vars.user;

    #Network
    networking.hostName = vars.host;
    networking.networkmanager.enable = true;

    time.timeZone = vars.timeZone;
    
    i18n.defaultLocale = "en_US.UTF-8"; # Programs language
    
    system.stateVersion = vars.systemVersion;
}

