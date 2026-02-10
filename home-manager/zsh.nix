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
                    git add . && \
                    git commit -m "Update" && \
                    nh os switch && \
                    nh home switch && \
                    nh clean all --keep 3 --keep-since 3d
                )
            '';
            rebuild = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    nh os switch && \
                    nh home switch && \
                    nh clean all --keep 3 --keep-since 3d
                )
            '';
            reconf = ''
                (
                    cd ${vars.configPath} && \
                    git add . && \
                    nh home switch
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
