{ config, pkgs, vars, ... }: {
    programs = {
        gh = {
            enable = true;
            settings = {
                git_protocol = "ssh";
                color_labels = "enabled";
            };
        };
        git = {
            enable = true;
            settings = {
                user = {
                    name = "mrChest228";
                    email = "gengenm32111111@gmail.com";
                };
                url."ssh://git@github.com/".insteadOf = "https://github.com/";
                credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";

                init.defaultBranch = "main";
                pull.rebase = false;
            };
        };
    };
}
