{ config, lib, pkgs, vars, ... }:
{
    environment.shells = [ pkgs.unstable.nushell ];
    programs.bash.interactiveShellInit = '' # NuShell autostart
        if [[ "$TERM" != "dumb" ]] && [[ -z "$BASH_EXECUTION_STRING" ]]; then
            exec nu
        fi
    '';
}
