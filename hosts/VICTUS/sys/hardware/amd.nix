{ config, lib, pkgs, vars, self, ... }: {
    # CPU power limit 65W on AC and 15W on battery
    environment.systemPackages = [ pkgs.ryzenadj ];
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=100"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --fast-limit=20000 --slow-limit=15000 --stapm-limit=15000 --tctl-temp=75"
    '';
}
