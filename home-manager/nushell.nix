{ config, pkgs, vars, ... }:
{
    programs.nushell = {
        enable = true;
        settings = {
            show_banner = false;
        };
        extraConfig = ''
            
            def config-commit [message: string] {
                cd ${vars.configPath} || return 1
            }
        '';
        shellAliases = {
            tp = "trash-put";
        };
    };
}
