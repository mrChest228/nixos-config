{ config, lib, pkgs, vars, ... }:
{
    imports = [        
        ./modules/bootloader.nix
        ./modules/hardware
        ./hardware-configuration.nix

        ./modules/greetd.nix
        ./modules/hibernation.nix
        ./modules/power-management.nix
        ./modules/ccache.nix
        ./modules/sound.nix
        ./modules/hyprland.nix
        ./modules/zsh.nix

        ./modules/packages.nix
        ./modules/security.nix
        ./modules/nix.nix
    ];
    
    users.users.${vars.userName} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "";
    };
    # services.getty.autologinUser = vars.userName;

    #Network
    networking.hostName = vars.hostName;
    networking.networkmanager.enable = true;

    time.timeZone = vars.timeZone;
    
    i18n.defaultLocale = "en_US.UTF-8"; # Programs language

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    system.stateVersion = vars.systemVersion;
}

