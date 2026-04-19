{ config, lib, libs, pkgs, vars, self, ... }:
{
    imports = [
        ( libs.import-tree (self + /nixos) )
        ( libs.import-tree ./nixos )
        ( libs.import-tree ./hardware )
        libs.determinate.nixosModules.default
    ];
    
    users.users.${vars.user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "";
    };
    # services.getty.autologinUser = vars.user;

    time.timeZone = vars.timeZone;
    
    i18n.defaultLocale = "en_US.UTF-8"; # Programs language
}

