{ config, lib, libs, pkgs, vars, self, ... }:
{
    networking = {
        #TODO: hosts with My server (if the Internet or electricy will be disabled (for local network))
        nameservers = [
            "1.1.1.1#cloudflare-dns.com"
            "2606:4700:4700::1111#cloudflare-dns.com"
            "8.8.8.8#dns.google"
            "2001:4860:4860::8888#dns.google"
            "1.0.0.1#cloudflare-dns.com"
            "2606:4700:4700::1001#cloudflare-dns.com"
        ];
        networkmanager = {
            enable = true;
            dns = lib.mkForce "none"; # Don't use default dns from my router. Only my own dns
            settings.main.systemd-resolved = false;
            connectionConfig = {
                "ipv6.ip6-privacy" = 2;        # Use random-generated IP-adresses (static IP continue working)
            };
        };
        useDHCP = false;
        dhcpcd.enable = false;
        resolvconf.enable = false;
    };
    services.resolved = {
        enable = true;
        settings.Resolve = {
            DNSOverTLS = true;
            Domains = [ "~." ];
            FallbackDNS = []; # Don't use uncrypted DNS
            LLMNR = false;    # An old protocol
            DNSSEC = false;   # Cloudflare and google already check the sertificates. Saves time
            MulticastDNS = true;
        };
    };
    boot.kernel.sysctl = {
        # Network speed up
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_ecn" = 1;
    };
}
