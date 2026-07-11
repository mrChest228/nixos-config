rec { # For using attrs that was created in this file
    arch = "x86_64-linux";
    
    users = [
        "mrChest"
    ];
    # configPath = "/etc/nixos"; # TODO
    configPath = "/etc/nixos";
    
    timeZone = "Europe/Minsk";
}
