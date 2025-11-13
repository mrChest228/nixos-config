{ config, lib, pkgs, vars, ... }:
{
    hardware = {
        graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                # Diagnostic utilities
                vulkan-tools
                # Driver for hardware video acceleraion
                nvidia-vaapi-driver # For nvidia, amd driver is already installed
                # Compatibillity bridge for applications, using old api
                libvdpau-va-gl
            ];
        };
        nvidia = {
            modesetting.enable = true;
            open = false;
            powerManagement = {
                enable = true;
                finegrained = true;
            };
            prime = {
                offload = {
                    enable = true;
                    enableOffloadCmd = true;
                };
                amdgpuBusId = "PCI:06:00:0"; # Watch by lspci | grep -i "VGA" (needs pciutils package)
                nvidiaBusId = "PCI:01:00:0";
            };
        };
    };
    services = {
        xserver.videoDrivers = [ "nvidia" ];
        tlp.settings.RUNTIME_PM_BLACKLIST = "01:00:0"; # Remove discrete GPU from tlp power-management control
    };

    boot = {
        initrd.availableKernelModules = [ "nvidia" ];
        kernelParams =  [ "nvidia-drm.modeset=1" ];
        blacklistedKernelModules = [ "nouveau" ]; # Disable not proprietary nvidia driver for boot's speeding up
        extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.production ];
    };

    environment.sessionVariables = {
        WLR_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1"; # NVIDIA's first, amdgpu's second 
    };
}
