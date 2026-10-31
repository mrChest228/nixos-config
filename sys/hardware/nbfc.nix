{ config, lib, pkgs, vars, com, cur, ... }: {
    services.nbfc-linux = {
        enable = true;
        settings = {
            profile = "HP Victus 15-fb0xxx";
        };
    };
}
