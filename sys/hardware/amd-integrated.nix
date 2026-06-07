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
    };
    # Power limit 15W on battery
    environment.systemPackages = [ pkgs.ryzenadj ];
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=100" # High power limit on AC
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --fast-limit=20000 --slow-limit=15000 --stapm-limit=15000 --tctl-temp=75"  # Low power limit on battery
    '';

    services.xserver.videoDrivers = [ "amdgpu" ];
}
