{ config, pkgs, vars, ... }:
{
    programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";

        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
            size = 10000;
            path = "${config.xdg.dataHome}/zsh/zsh_history";
        };

        shellAliases = {
            update = ''
                (
                    cd ${vars.configPath} && \
                    sudo nix flake update && \
                    sudo nixos-rebuild switch --flake .#${vars.host} && \
                    home-manager switch --flake .#${vars.user}
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} && \
                    sudo nixos-rebuild switch --flake .#${vars.host} && \
                    home-manager switch --flake .#${vars.user}
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} && \
                    home-manager switch --flake .#${vars.user}
                )
            '';
            tp = "trash-put";
        };
        
        oh-my-zsh = {
            enable = true;
            # plugins = [];
            # theme = "";
        };
    };
}
