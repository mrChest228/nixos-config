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
                    if [ -z $1 ]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name: \"Update $(date +\"%Y-%m-%d %H:%M\")\""
                        git commit -m "Update $(date +\"%Y-%m-%d %H:%M\")"
                    fi
                    nh os switch . && \
                    nh home switch . && \
                    nh clean all --keep 3 --keep-since 3d
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    if [ -z $1 ]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name: \"Rebuild $(date +\"%Y-%m-%d %H:%M\")\""
                        git commit -m "Rebuild $(date +\"%Y-%m-%d %H:%M\")"
                    fi
                    nh os switch . && \
                    nh home switch . && \
                    nh clean all --keep 3 --keep-since 3d
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    if [ -z $1 ]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name: \"Reconf $(date +\"%Y-%m-%d %H:%M\")\""
                        git commit -m "Reconf $(date +\"%Y-%m-%d %H:%M\")"
                    fi
                    nh home switch .
                )
            '';
        };
        shellAliases = {
            tp = "trash-put";
        };
        
        oh-my-zsh = {
            enable = true;
            # plugins = [];
            # theme = "";
        };
    };
}
