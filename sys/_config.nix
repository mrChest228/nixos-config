{ config, lib, pkgs, vars, com, cur, get, ... }: {
    imports = get [
        (com + /sys/options/...)
        (com + /sys)
        (com + /sys/config/cfg.nix)
        (com + /sys/config/gen.nix)
        (com + /sys/config/update.nix)
        (com + /sys/config/rebuild.nix)
        (com + /sys/config/reconf.nix)
        (com + /sys/config/clean.nix)
        (com + /sys/config/git.nix)
        ./hardware
        ./.
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
