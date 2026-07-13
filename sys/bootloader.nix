{ config, lib, pkgs, vars, ... }:
{
    boot = {
        loader = {
            efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot";
            };
            systemd-boot = {
                enable = true;
                editor = false; # For security
            };
            timeout = 3; # Gens selecting pause
        };
        initrd = {
            systemd.enable = true;
            # Compress the images
            compressor = "zstd";
            compressorArgs = [ "-15" "-T0" ]; # zstd 15 level, use all CPU cores
        };
        kernel.sysctl = {
        };
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
            # Optimizations
            # "quiet"                     # Minimize kernel output (speeds up)
            # "initcall_debug=n"          # Disables debug calls (speeds up)
            # "systemd.show_status=0"     # Hide loading status (speeds up)
            "loglevel=3"                  # Shows only critical errors
            "pcie=noaer"                  # Disable PCIe error logging
            "zstd.zstd_workers=6" # TODO: make it bigger or lower
        ];
    };
    systemd.services = {
        NetworkManager-wait-online.enable = false; # Don't wait, before NetworkManager find a network - continue bootloading and connect in parallel
    };
    # Bcachefs
    boot = {
        supportedFilesystems = [ "bcachefs" ];
        initrd.availableKernelModules = [ "crc32c" ]; # Fast hashing
        kernelModules = [ "bcachefs" ];
    };
}
