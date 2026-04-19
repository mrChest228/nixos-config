{ config, lib, libs, pkgs, vars, self, ... }:
{
    networking = {
        hostName = vars.host;
        networkmanager.enable = true;
        nameservers = [
            "1.1.1.1"
            "8.8.8.8"
            "1.0.0.1"
        ];
    };
}
