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
            availableKernelModules = [
                "nvme" "xhci_pci" "uas" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" # It was generated at hardware-configuration.nix
                "amdgpu" "nvidia" # Ensures, that amdgpu boots before the desktop
            ];
        };
        kernelPackages = pkgs.stable.linuxPackages_latest; # Latest stable kernel
        kernelModules = [ "kvm-amd" ];                     # It was generated at hardware-configuration.nix
        extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.production ];
        blacklistedKernelModules = [ "nouveau" ];          # Disable not proprietary nvidia driver for boot's speed up
        kernel.sysctl."vm.swappiness" = 10;                # Lower count of swap using
        kernelParams = [
            # Optimizations
            # "quiet"                     # Minimize kernel output (speeds up)
            # "initcall_debug=n"          # Disables debug calls (speeds up)
            # "systemd.show_status=0"     # Hide loading status (speeds up)
            "loglevel=3"                # Shows only critical errors
            "pcie_aspm=off"             # Removes lags
            "amd_pstate=active"         # Optimizing processor perfomance mode
            "random.trust_cpu=1"        # Disable using the entripy (the loading is speeding up)

            # nvidia
            "nvidia-drm.modeset=1"

            # Swap
            "resume=UUID=${vars.UUIDs.swap}"

            # Sleep
            "mem_sleep_default=deep"
        ];
    };
    systemd.services = {
        # NetworkManager-wait-online.enable = false; # Don't wait, before NetworkManager find a network - continue bootloading and connect in parallel
    };
}
