{ config, lib, pkgs, vars, self, ... }: {
    programs = {
        niri.enable = true;
        # Autostart
        bash.loginShellInit = ''
            if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
                exec niri-session -l
            fi
        '';
    };
    systemd.services."getty@tty1" = {
        overrideStrategy = "asDropin";
        serviceConfig.TTYVTDisallocate = "no";
        serviceConfig.ExecStart = [
            ""
            "-${pkgs.util-linux}/bin/agetty --noclear --skip-login --login-options \"-f ${config.services.getty.autologinUser}\" %I $TERM"
        ];
    };
}
