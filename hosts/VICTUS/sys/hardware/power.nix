{ config, lib, pkgs, vars, self, ... }: {
    # CPU power limit 65W on AC and 15W on battery and nvidia-powerd/nvidia-persisteced disabling on BAT
    environment.systemPackages = [ pkgs.ryzenadj ];
    systemd.services.power-manager = let
        ACPath = "/sys/class/power_supply/ACAD";
    in {
        description = "Manage power limits, enabled services and system settings based on AC connection";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];

        unitConfig.StartLimitIntervalSec = 0; # Restart the service as often as I plug AC-adapter

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
                systemctl unmask nvidia-persistenced.service || true # Unblock nvidia-persistenced enabling
                systemctl start nvidia-persistenced.service nvidia-powerd.service || true

                while true; do
                    ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=97
                    sleep 3
                done
            else
                systemctl stop nvidia-persistenced.service nvidia-powerd.service || true
                systemctl mask nvidia-persistenced.service || true # Block nvidia-persistenced enabling

                while true; do
                    ryzenadj --fast-limit=30000 --slow-limit=30000 --stapm-limit=30000 --tctl-temp=80
                    sleep 3
                done
            fi
        '';
    };
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart power-manager"
    '';
}
