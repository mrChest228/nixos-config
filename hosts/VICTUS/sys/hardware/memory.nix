{ config, lib, pkgs, vars, self, ... }: {
    fileSystems = {
        # Partitions
        "/" = {
            device = "/dev/disk/by-partlabel/${vars.host}-root";
            fsType = "bcachefs";
            options = [
                "noatime"
                "compression=zstd:1" # Fast compression
                "discard"   # Async TRIM
            ];
        };
        # Bind-mounts (X-mount.mkdir option to create the target folder)
        "${vars.configPath}/host" = {
            device = "${vars.configPath}/hosts/${vars.host}";
            fsType = "none";
            options = [ "bind" "X-mount.mkdir" ];
        };
    } // (lib.mergeAttrsList (builtins.map (user:
        if lib.hasPrefix "/home/${user}" vars.configPath then
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
        "d /home/%U/.local/share/Trash 0700 ${user} ${user} 180d -" # Folder crafting and auto-deleting
        "h /home/%U/.local/share/Trash - - - - bcachefs.background_compression=zstd:19"
    ];
    
    # Swap partition is in sys/zswap.nix (todo + let swapPath = "/dev/disk..." and use in swapDevices and boot.resumeDevice)
    boot = {
        kernel.sysctl = {
            "vm.swappiness" = 50      ; # Count of swap using (0..100 value) and zram compressing start time (50 is about 80% of RAM)
            "vm.overcommit_memory" = 2; # Don't allocate more memory than RAM + Swap are
            "vm.overcommit_ratio" = 95; # Accept to allocate almost all the available RAM
        };
        resumeDevice = "/dev/disk/by-partlabel/${vars.host}-swap";
    };

    # Optimizations
    services = {
        fstrim.enable = false;
        bcachefs.autoScrub = {
            enable = true;
            interval = "weekly";
            fileSystems = [ "/" ];
        };
        # btrfs.autoScrub = {
        #     enable = true;
        #     interval = "monthly";
        # };
    };
    environment.systemPackages = with pkgs; [
        bcachefs-tools
        btrfs-progs
        smartmontool # TODO: check. For watching the disk health
    ];
}
