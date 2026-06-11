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
        serviceConfig.ExecStart = [
            ""
            "-${pkgs.util-linux}/bin/agetty --noclear --skip-login%I $TERM --login-program ${config.programs.niri.package}/bin/niri-session -- -l"
        ];
    };
}
