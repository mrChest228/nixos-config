{ config, lib, pkgs, vars, ...  }:
{
    console.earlySetup = true; # Early loading fonts (e. g. password input for lucks)
    systemd.services.systemd-vconsole-setup.postStart = "kbdrate -s -r 15 -d 250"; # Fast typing in tty
}
