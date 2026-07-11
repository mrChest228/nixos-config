{ config, lib, pkgs, vars, ... }: {
    services = {
        power-profiles-daemon.enable = false; # TLP is better
        tlp = {
            enable = true;
            settings = {
                # Alternating Current
                # CPU_ENERGY_PERF_POLICY_ON_AC = "balance_perfomance"; # For intel

                RUNTIME_PM_ON_AC = "on";
                MAX_LOST_WORK_SECS_ON_AC = 20;

                # Battery
                # CPU_ENERGY_PERF_POLICY_ON_BAT = "power"; # For intel

                WIFI_PWR_ON_BAT = "on";
                SOUND_POWER_SAVE_ON_BAT = 1;
                SOUND_POWER_SAVE_CONTROLLER = "Y";
                PCIE_ASPM_ON_BAT = "powersave";
                RUNTIME_PM_ON_BAT = "auto";
                MAX_LOST_WORK_SECS_ON_BAT = 60;
                NMI_WATCHDOG = 0;

                # Doesn't work on VICTUS :(
                START_CHARGE_THRESH_BAT0 = 85;
                STOP_CHARGE_THRESH_BAT0 = 98;
            };
        };
        upower.enable = true; # Power (battery, AC) info
    };
    environment.systemPackages = [ pkgs.lm_sensors ];
    # programs.mangohud.enable = true; # TODO
}
