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

        siteFunctions = {
            update = ''
                (
                    cd ${vars.configPath} && \
                    nix flake update && \
                    git add . && \
                    if [[ "$1" ]]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name\e[0m: \"Update $(date +'%Y-%m-%d %H:%M')\""
                        git commit -m "Update $(date +'%Y-%m-%d %H:%M')"
                    fi
                    git push
                    sudo nixos-rebuild switch --flake .#${vars.host} && \
                    home-manager switch --flake .#${vars.user} && \
                    # TODO: remove the previous generation
                    sudo gen-clean
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    if [[ "$1" ]]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name\e[0m: \"Rebuild $(date +'%Y-%m-%d %H:%M')\""
                        git commit -m "Rebuild $(date +'%Y-%m-%d %H:%M')"
                    fi
                    git push
                    sudo nixos-rebuild switch --flake .#${vars.host} && \
                    home-manager switch --flake .#${vars.user} && \
                    sudo gen-clean
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    if [[ "$1" ]]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name\e[0m: \"Reconf $(date +'%Y-%m-%d %H:%M')\""
                        git commit -m "Reconf $(date +'%Y-%m-%d %H:%M')"
                    fi
                    git push
                    home-manager switch --flake .#${vars.user}
                    # TODO: hm-clean script
                )
            '';
        };
        shellAliases = {
            tp = "trash-put";
            gen-list = "nixos-rebuild list-generations";
        };
        
        oh-my-zsh = {
            enable = true;
            # plugins = [];
            # theme = "";
        };
    };
}
