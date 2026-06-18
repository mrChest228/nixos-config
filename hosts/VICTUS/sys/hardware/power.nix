{ config, lib, pkgs, vars, self, ... }: {
    # CPU power limit 65W on AC and 15W on battery and nvidia-powerd/nvidia-persisteced disabling on BAT
    environment.systemPackages = [ pkgs.ryzenadj ];
    systemd.services.cpu-power-limits = let
        ACPath = "/sys/class/power_supply/ACAD";
    in {
        description = "Set needed CPU power limits based on AC connection";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            # Type = "oneshot";
            # RemainAfterExit = true;
            Type = "simple";
            Restart = "always";
        };

        path = with pkgs; [
            ryzenadj
            systemd
        ];

        # TODO: slow and stapm limits 65W on AC?
        script = ''
            while true; do
                if [ -f ${ACPath}/online ] && [ "$(cat ${ACPath}/online)" == "1" ]; then
                    ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=97
                    systemctl unmask nvidia-persistenced.service # Block nvidia-persistenced enabling
                    systemctl start nvidia-persistenced.service nvidia-powerd.service
                else
                    ryzenadj --fast-limit=30000 --slow-limit=30000 --stapm-limit=30000 --tctl-temp=80
                    systemctl stop nvidia-persistenced.service nvidia-powerd.service
                    systemctl mask nvidia-persistenced.service
                fi
                sleep 3
            done
        '';
    };
}
