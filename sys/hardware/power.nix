{ config, lib, pkgs, vars, ... }: {
    # powerManagement.powertop.enable = true; # Automatically optimize machine energy consumption (for longer life on battery)
    services = {
        power-profiles-daemon.enable = false; # TLP is better
        tlp = {
            enable = true;
            settings = {
                # Alternating current
                PLATFORM_PROFILE_ON_AC = "performance";
                # CPU_ENERGY_PERF_POLICY_ON_AC = "balance_perfomance"; # For intel
                AMD_ENERGE_PERF_POLICY_ON_AC = "balance_perfomace";

                # Battery
                PLATFORM_PROFILE_ON_BAT = "quiet"; # TODO: move to ./host
                # CPU_ENERGY_PERF_POLICY_ON_BAT = "power"; # For intel
                AMD_ENERGY_PERF_POLICY_ON_BAT = "power"; # TODO: move specific settings to ./hardware/amd

                WIFI_PWR_ON_BAT = "on";
                SOUND_POWER_SAVE_ON_BAT = "on";
                PCIE_ASPM_ON_BAT = "powersave";
                # Doesn't work on VICTUS :(
                START_CHARGE_THRESH_BAT0 = 85;
                STOP_CHARGE_THRESH_BAT0 = 98;

                # RUNTIME_PM_DRIVER_DENYLIST = "nouveau nvidia";
            };
        };
        upower.enable = true; # Power (battery, AC) info
    };
    # TODO: move lm_sensors here
    # programs.mangohud.enable = true; # TODO
}
