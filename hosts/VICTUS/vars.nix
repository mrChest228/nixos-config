rec { # For using attrs that was created in this file
    arch = "x86_64-linux";
    
    UUIDs = {
        root = "80e2ad07-2a1c-4e91-9bde-b67cd9888e78";
        swap = "41e22e4c-9572-47da-aebd-c908ce7c1250";
    };
    
    users = [
        "mrchest"
    ];
    # configPath = "/etc/nixos"; # TODO
    configPath = "/home/mrchest/config";
    
    timeZone = "Europe/Minsk";
}
