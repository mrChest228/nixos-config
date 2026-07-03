{ config, lib, pkgs, vars, self, ... }: {
    services.nbfc = {
        enable = true;
        settings = {
            profile = "HP Victus 15-fb0xxx";
        };
    };
}
