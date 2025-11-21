{ config, lib, pkgs, vars, ... }:
{
    imports = [
        ( inputs.import-tree ./modules )
        ( inputs.import-tree /etc/nixos/hosts/${vars.host}/hardware )
        ( inputs.import-tree /etc/nixos/hosts/${vars.host}/nixos )
    ];
    
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

