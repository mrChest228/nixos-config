{ config, lib, libs, pkgs, vars, self, ... }:
{
    networking = {
        hostName = vars.host;
        nameservers = [
            "1.1.1.1"
            "8.8.8.8"
            "1.0.0.1"
        ];
        networkmanager = {
            enable = true;
            dns = "none"; # Don't manage /etc/resolv.conf
        };
        resolvconf.enable = false; # Don't use default dns from my router. Only my own dns
    };
}
