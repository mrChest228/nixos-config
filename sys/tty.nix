{ config, lib, pkgs, vars, self, ... }: {
    console.earlySetup = true; # Early loading fonts (e. g. password input for lucks)
    systemd.services.systemd-vconsole-setup.postStart = "${pkgs.kbd}/bin/kbdrate -s -r 15 -d 250"; # Fast typing in tty
    environment.systemPackages = [ pkgs.kbd ];
}
