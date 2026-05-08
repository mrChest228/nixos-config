{ config, vars, ... }: {
    programs.git = {
        enable = true;
        config.safe.directory = [
            vars.configPath
        ];
    };
}
