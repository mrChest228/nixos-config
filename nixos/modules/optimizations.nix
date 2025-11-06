{
    # Disk optimizations
    services = {
        fstrim.enable = true;
        btrfs.autoScrub = {
            enable = true;
            interval = "monthly";
        };
    };
    zramSwap = {
        enable = true; # Compress unactive RAM (zstd)
        memoryPercent = 100;
        priority = 999;
    };
    programs.ccache.enable = true; # Optimizes recompilation of the same files
}
