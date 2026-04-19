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
            connectionConfig = { # Don't use default dns from my router
                "ipv4.ignore-auto-dns" = "yes";
                "ipv6.ignore-auto-dns" = "yes";
            };
        };
    };
}
