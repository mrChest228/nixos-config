{ config, lib, pkgs, vars, ... }:
{
    hardware.amdgpu.initrd.enable = true;
    boot = {
        initrd = {
            # Drivers preloading
            kernelModules = [ "amdgpu" ];
            availableKernelModules = [ "amdgpu" ];
        };
        kernelParams = [
            "amd_pstate=active"  # Optimizing processor perfomance mode
            "random.trust_cpu=1" # Disable using the entripy (the loading will speed up)
        ];
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
}
