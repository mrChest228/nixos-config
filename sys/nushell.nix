{ config, lib, pkgs, vars, ... }:
{
    environment.systemPackages = [ pkgs.nushell ];
    environment.shells = [ pkgs.nushell ];
    programs.bash.interactiveShellInit = '' # NuShell autostart
        if [[ "$TERM" != "dumb" ]] && [[ -z "$BASH_EXECUTION_STRING" ]] && [[ $(ps -p $PPID -o comm=) != "nu" ]]; then
            exec nu --config ~/.config/nushell/config.nu --env-config ~/.config/nushell/env.nu
        fi
    '';
}
