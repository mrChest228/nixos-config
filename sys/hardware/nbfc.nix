{ config, lib, com, pkgs, vars, self, ... }: {
    services.nbfc-linux = {
        enable = true;
        settings = {
            profile = "HP Victus 15-fb0xxx";
        };
    };
}
