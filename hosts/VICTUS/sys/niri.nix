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
}
