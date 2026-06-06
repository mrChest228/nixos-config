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
        kernelPackages = pkgs.stable.linuxPackages_latest; # The latest stable kernel
        kernelParams = [
            # Optimizations
            # "quiet"                     # Minimize kernel output (speeds up)
            # "initcall_debug=n"          # Disables debug calls (speeds up)
            # "systemd.show_status=0"     # Hide loading status (speeds up)
            "loglevel=3"                  # Shows only critical errors
            "pcie=noaer"                  # Disable PCIe error logging
        ];
    };
    systemd.services = {
        NetworkManager-wait-online.enable = false; # Don't wait, before NetworkManager find a network - continue bootloading and connect in parallel
    };
}
