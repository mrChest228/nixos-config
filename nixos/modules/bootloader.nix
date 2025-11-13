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
            timeout = 3; # Loader pause
        };
        initrd = {
            systemd.enable = true; # Speeds up boot
            compressor="zstd";
        };
        kernelPackages = pkgs.stable.linuxPackages_latest; # Latest stable kernel
        kernelParams = /*lib.unique ((config.boot.kernelParams or []) ++*/ [ # Supplemented in nvidia.nix, amd.nix, disks.nix and hibernation.nix
            # Optimizations
            # "quiet"                     # Minimize kernel output (speeds up)
            # "initcall_debug=n"          # Disables debug calls (speeds up)
            # "systemd.show_status=0"     # Hide loading status (speeds up)
            "loglevel=3"                # Shows only critical errors
            "pcie_aspm=off"             # Removes lags
        ];
    };
    systemd.services = {
        # NetworkManager-wait-online.enable = false; # Don't wait, before NetworkManager find a network - continue bootloading and connect in parallel
    };
}
