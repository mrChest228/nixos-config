{ config, lib, pkgs, vars, ... }:
{
    programs.nushell.enable = true;
    programs.bash.interactiveShellInit = '' # NuShell autostart
        if [[ "$TERM" != "dumb" ]] && [[ -z "$BASH_EXECUTION_STRING" ]]; then
            exec nu
        fi
    '';
}
