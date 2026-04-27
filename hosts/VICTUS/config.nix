{ config, lib, libs, pkgs, vars, self, ... }:
{
    imports = [
        ( libs.import-tree ./sys/hardware )
        ( libs.import-tree (self + /sys) )
        ( libs.import-tree ./sys )
        libs.determinate.nixosModules.default
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

