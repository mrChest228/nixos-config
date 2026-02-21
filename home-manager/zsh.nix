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
                    local code=$?
                    local command=''${$(printf "%q " "$@")% }
                    echo -e "\e[1;31mCommand \"$command\" FAILED (exit code $code)\e[0m"
                    return $code
                }
            '';
            config-commit = ''
                (
                    cd ${vars.configPath} || return 1
                    git add .
                    if [[ -n $(git status --porcelain) ]]; then
                        # Print file changes
                        git status --porcelain | sed -e 's/^A/\x1b[32m+ /' -e 's/^D/\x1b[31m- /' -e 's/^M/\x1b[33mc /' -e 's/$/\x1b[0m/'
                        local msg="''${1:-Commit $(date +'%Y-%m-%d %H:%M')}"
                        # Commit
                        silent git commit -m "$msg" && \
                        # Print commit info
                        git --no-pager log -1 --oneline && \
                        # push
                        silent git push && echo -e "\e[1;32mSuccessful push\e[0m"
                    else
                        echo -e "\e[1;36mNothing to commit\e[0m"
                    fi
                )
            '';
            # TODO: use nh, remove ( cd ... )
            update = ''
                (
                    cd ${vars.configPath} || return 1
                    config-commit "''${1:-Update $(date +'%Y-%m-%d %H:%M')}"
                    sudo nixos-rebuild switch --flake .#${vars.host} || return 2
                    home-manager switch --flake .#${vars.user}
                    # TODO: remove the previous generation

                    nh clean all --keep 3 --keep-since 3d --nogc --nogcroots && \
                    sudo /run/current-system/bin/switch-to-configuration boot
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} || return 1
                    config-commit "''${1:-Rebuild $(date +'%Y-%m-%d %H:%M')}"
                    sudo nixos-rebuild switch --flake .#${vars.host} || return 2
                    home-manager switch --flake .#${vars.user}

                    nh clean all --keep 3 --keep-since 3d --nogc --nogcroots && \
                    sudo /run/current-system/bin/switch-to-configuration boot
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} || return 1
                    config-commit "''${1:-Reconf $(date +'%Y-%m-%d %H:%M')}"
                    home-manager switch --flake .#${vars.user}

                    nh clean all --keep 3 --keep-since 3d --nogc --nogcroots && \
                    sudo /run/current-system/bin/switch-to-configuration boot
                )
            '';
            gen = ''
                local action=$1
                local id=$2

                case "$action" in
                    list)
                        nh os info
                    ;;
                    del)
                        
                    ;;
                    switch)

                    ;;
                esac
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
