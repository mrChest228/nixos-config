{ config, lib, pkgs, vars, self, ... }:
{
    fileSystems = {
        # Partitions
        "/" = {
            device = "/dev/disk/by-uuid/${vars.UUIDs.root}";
            fsType = "btrfs";
            options = [
                "noatime"
                "compress=zstd:1" # Fast compression
                "ssd"             # SSD optimizations
                "discard=async"   # Async TRIM (hz)
                "space_cache=v2"  # Effectieve caching
                "autodefrag"
            ];
        };
        "/boot" = { # ESP
            device = "/dev/disk/by-uuid/${vars.UUIDs.esp}";
            fsType = "vfat";
        };
        # Bind-mounts (X-mount.mkdir option to create the target folder)
        "${vars.configPath}/host" = {
            device = "${vars.configPath}/hosts/${vars.host}";
            fsType = "none";
            options = [ "bind" "X-mount.mkdir" ];
        };
    } // (lib.mergeAttrsList (builtins.map (user:
        if lib.hasPrefix "/home/${user}" vars.flakePath then
            {}
        else {
            "/home/${user}/cfg" = {
                device = "${vars.configPath}";
                fsType = "none";
                options = [ "bind" "X-mount.mkdir" ];
            };
        }
    ) vars.users));

    systemd.tmpfiles.rules = [
        # "d /home/${user}/.local/share/Trash 0700 ${user} ${user} - -"
    ];
    # TODO: trash big compression
    
    # Swap partition
    swapDevices = [{
        device = "/dev/disk/by-uuid/${vars.UUIDs.swap}";
    }];
    boot = {
        kernel.sysctl = {
            "vm.swappiness" = 20; # Count of swap using (0..100 value)
            "vm.overcommit_memory" = 2; # Don't allocate more memory than RAM + Swap are
            "vm.overcommit_ratio" = 95; # Accept allocate almost all the available RAM
        };
        kernelParams = [ "resume=UUID=${vars.UUIDs.swap}" ];
    };

    # Optimizations
    services = {
        fstrim.enable = true;
        btrfs.autoScrub = {
            enable = true;
            interval = "monthly";
        };
    };
}
