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
            silent = ''
                chronic "$@" || {
                    echo -e "\e[1;31mCommand \"$(printf "%q " "$@")\" FAILED (exit code $?)\e[0m"
                    return $?
                }
            '';
            update = ''
                (
                    cd ${vars.configPath} || return 1
                    nix flake update || return 2
                    git add .
                    if [[ "$1" ]]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name\e[0m: \"Update $(date +'%Y-%m-%d %H:%M')\""
                        git commit -m "Update $(date +'%Y-%m-%d %H:%M')"
                    fi
                    git push
                    sudo nixos-rebuild switch --flake .#${vars.host} || return 3
                    home-manager switch --flake .#${vars.user}
                    # TODO: remove the previous generation
                    sudo gen-clean
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} || return 1
                    git add .
                    if [[ "$1" ]]; then
                        git commit -m "$1"
                    else
                        echo "\e[1;32mGit commit name\e[0m: \"Rebuild $(date +'%Y-%m-%d %H:%M')\""
                        git commit -m "Rebuild $(date +'%Y-%m-%d %H:%M')"
                    fi
                    git push
                    sudo nixos-rebuild switch --flake .#${vars.host} || return 3
                    home-manager switch --flake .#${vars.user}
                    sudo gen-clean
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} || return 1
                    git add .
                    if [[ `git status --porcelain` ]]; then
                        # Print file changes
                        git status --porcelain | sed -e 's/^A/\x1b[32m+ /' -e 's/^D/\x1b[31m- /' -e 's/^M/\x1b[33mc /' -e 's/$/\x1b[0m/'
                        local msg="''${1:-Reconf $(date +'%Y-%m-%d %H:%M')}"
                        # Commit
                        chronic git commit -m "$msg" || echo -e "\e[1;31mCommand \"\" FAILED (exit code $?)\e[0m"
                        # Print commit info
                        git --no-pager log -1 --oneline
                        # push
                    else
                        echo -e "\e[1;36mNothing to commit\e[0m"
                    fi
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
