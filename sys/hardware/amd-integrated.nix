{ config, lib, pkgs, vars, ... }:
{
    hardware = {
        amdgpu.initrd.enable = true;
        cpu.amd.updateMicrocode = true;
        enableRedistributableFirmware = true;
    };
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
        # New amd-sensors module instead of built-in k10temp
        blacklistedKernelModules = [ "k10temp" ];
        extraModulePackages = with config.boot.kernelPackages; [
            zenpower
            ryzen-smu
        ];
        kernelModules = [
            "zenpower"
            "ryzen_smu"
        ];
    };
    environment.systemPackages = [ pkgs.ryzenadj ];

    services = {
        xserver.videoDrivers = [ "amdgpu" ];
        tlp.settings = {
            AMD_ENERGE_PERF_POLICY_ON_AC = "balance_performace";
            AMD_ENERGY_PERF_POLICY_ON_BAT = "power";
        };
    };
}
