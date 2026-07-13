{ config, lib, pkgs, vars, self, ... }: {
    environment = {
        systemPackages = [ pkgs.nushell ];
        shells = [ pkgs.nushell ];
    };
    # Autostart
    programs.bash.interactiveShellInit = ''
        if [[ "$TERM" != "dumb" ]] && [[ -z "$BASH_EXECUTION_STRING" ]] && [[ $(ps -p $PPID -o comm=) != "nu" ]]; then
            exec nu --config ~/.config/nushell/config.nu --env-config ~/.config/nushell/env.nu
        fi
    '';
}
