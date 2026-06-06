{ config, lib, pkgs, vars, ... }: {
    powerManagement.powertop.enable = true; # Automatically optimize machine energy consumption (for longer life on battery)
    services = {
        power-profiles-daemon.enable = false; # TLP is better
        tlp = {
            enable = true;
            settings = {
                # Alternating current
                CPU_ENERGY_PERF_POLICY_ON_AC = "perfomance";
                CPU_SCALING_GOVERNOR_ON_AC = "perfomance"; # amd_pstate is the main one
                AMD_ENERGE_PERF_POLICY_ON_AC = "balance_perfomace";
                # Battery
                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # amd_pstate is the main one
                AMD_ENERGY_PERF_POLICY_ON_BAT = "power"; # TODO: move specific settings to ./hardware/amd

                WIFI_PWR_ON_BAT = "on";
                SOUND_POWER_SAVE_ON_BAT = "on";
                PCIE_ASPM_ON_BAT = "powersave";
                USB_AUTOSUSPEND = 1;
                # Doesn't work on VICTUS :(
                START_CHARGE_THRESH_BAT0 = 85;
                STOP_CHARGE_THRESH_BAT0 = 98;
            };
        };
        thermald.enable = true; # Temperature and power control. Prevents overheating
        upower.enable = true; # Power (battery, AC) info
    };
    # TODO: move lm_sensors here
    # programs.mangohud.enable = true; # TODO
}
