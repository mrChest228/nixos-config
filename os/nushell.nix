{ config, lib, pkgs, vars, ... }:
{
    environment.systemPackages = [ pkgs.unstable.nushell ];
    environment.shells = [ pkgs.unstable.nushell ];
    programs.bash.interactiveShellInit = '' # NuShell autostart
        if [[ "$TERM" != "dumb" ]] && [[ -z "$BASH_EXECUTION_STRING" ]] && [[ $(ps -p $PPID -o comm=) != "nu" ]]; then
            exec nu --config /home/${vars.user}/.config/nushell/config.nu --env-config /home/${vars.user}/.config/nushell/env.nu
        fi
    '';
}
