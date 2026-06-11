{ config, lib, pkgs, vars, self, ... }: {
    # CPU power limit 65W on AC and 15W on battery
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
        ];

        script = ''
            if [ -f ${ACPath}/online ] && [ "$(cat ${ACPath}/online)" == "1" ]; then
                while true; do
                    ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=100
                    sleep 2
                done
            else
                while true; do
                    ryzenadj --fast-limit=35000 --slow-limit=20000 --stapm-limit=35000 --tctl-temp=75
                    sleep 2
                done
            fi
        '';
    };
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl restart cpu-power-limits"
    '';
}
