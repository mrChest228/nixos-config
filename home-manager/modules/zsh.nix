{ config, pkgs, vars, ... }:
{
    programs.zsh = {
        enable = true;

        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
            size = 10000;
            path = "${config.xdg.dataHome}/zsh/zsh_history";
        };

        shellAliases = {
            update = ''
                (
                    cd /etc/nixos && \
                    sudo nix flake update && \
                    sudo nixos-rebuild switch --flake .#${vars.userName} && \
                    home-manager switch --flake .#${vars.userName}
                )
            '';
            rebuild = ''
                (
                    cd /etc/nixos && \
                    sudo nixos-rebuild switch --flake .#${vars.userName} && \
                    home-manager switch --flake .#${vars.userName}
                )
            '';
            reconf = ''
                (
                    cd /etc/nixos && \
                    home-manager switch --flake .#${vars.userName}
                )
            '';
        };
        
        oh-my-zsh = {
            enable = true;
            # plugins = [];
            # theme = "";
        };
    };
}
