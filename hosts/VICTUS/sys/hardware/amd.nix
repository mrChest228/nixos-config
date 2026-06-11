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
            Type = "oneshot";
            RemainAfterExit = true;
        };

        path = with pkgs; [
            ryzenadj
        ];

        script = ''
            if [ -f ${ACPath}/online ] && [ "$(cat ${ACPath}/online)" == "1" ]; then
                ryzenadj --fast-limit=65000 --slow-limit=54000 --stapm-limit=65000 --tctl-temp=100
            else
                ryzenadj --fast-limit=20000 --slow-limit=15000 --stapm-limit=15000 --tctl-temp=75
            fi
        '';
    };
    services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl restart cpu-power-limits"
    '';
}
