{ config, lib, pkgs, vars, ... }:
{
    services = {
        power-profiles-daemon.enable = false;
        tlp = {
            enable = true;
            settings = {
                # Alternating current
                CPU_ENERGY_PERF_POLICY_ON_AC = "perfomance";
                CPU_SCALING__GOVERNOR_ON_AC = "schedutil";
                # Battery
                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                CPU_SCALING__GOVERNOR_ON_BAT = "powersave";
                WIFI_PWR_ON_BAT = "on";
                SOUND_POWER_SAVE_ON_BAT = "on";
                USB_AUTOSUSPEND = 1;
            };
        };
    };
    hardware.sensor.lm_sensors.enable = true; # Programs can use sensors now
    services.thermald.enable = true;
    programs.mangohud.enable = true;
}
