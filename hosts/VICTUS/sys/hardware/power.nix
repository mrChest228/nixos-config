{ config, lib, pkgs, vars, self, ... }: {
    # CPU power limit 65W on AC and 15W on battery and nvidia-powerd/nvidia-persisteced disabling on BAT
    environment.systemPackages = [ pkgs.ryzenadj ];
    systemd.services.power-manager = let
        ACPath = "/sys/class/power_supply/ACAD";
    in {
        description = "Manage power limits, enabled services and system settings based on AC connection";
        after = [
            "multi-user.target"
            "nvidia-powerd.service"
            "nvidia-persistenced.service"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "10s";
            KillMode = "mixed"; # Kill the bash-script without waiting to his sleep end
            TimeoutStopSec = "1s"; # Kill the process in 1 sec without waiting to himself killing after receiving the SIGTERM signal
        };

        path = with pkgs; [
            ryzenadj
            systemd
        ];

        # TODO: slow and stapm limits 65W on AC?
        script = ''
            if [ -f ${ACPath}/online ] && [ "$(cat ${ACPath}/online)" == "1" ]; then
                # systemctl start nvidia-powerd.service || true

                while true; do
                    ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=97
                    sleep 3
                done
            else
                # systemctl stop nvidia-powerd.service || true

                while true; do
                    ryzenadj --fast-limit=30000 --slow-limit=30000 --stapm-limit=30000 --tctl-temp=80
                    sleep 3
                done
            fi
        '';
    };
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", DEVPATH=="/devices/platform/*/power_supply/AC*", ENV{POWER_SUPPLY_ONLINE}=="0|1", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart power-manager"
    '';
}
