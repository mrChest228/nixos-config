{ config, lib, pkgs, vars, ... }: {
    services = {
        power-profiles-daemon.enable = false; # TLP is better
        tlp = {
            enable = true;
            settings = {
                # Alternating current
                CPU_ENERGY_PERF_POLICY_ON_AC = "perfomance";
                CPU_SCALING_GOVERNOR_ON_AC = "schedutil"; # Smart mode
                AMD_ENERGE_PERF_POLICY_ON_AC = "balance_power";
                # Battery
                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                CPU_SCALING_GOVERNOR_ON_BAT = "schedutil"; # Smart mode
                AMD_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # TODO: move specific settings to ./hardware/amd

                WIFI_PWR_ON_BAT = "on";
                SOUND_POWER_SAVE_ON_BAT = "on";
                USB_AUTOSUSPEND = 1;

                START_CHARGE_THRESH_BAT0 = 85;
                STOP_CHARGE_THRESH_BAT0 = 98;
            };
        };
        thermald.enable = true; # Temperature, fans and power control. Prevents overheating
        upower.enable = true; # Power (battery, AC) info
    };
    hardware.sensor.lm_sensors.enable = true; # Programs can use sensors now
    # programs.mangohud.enable = true; # TODO
}
