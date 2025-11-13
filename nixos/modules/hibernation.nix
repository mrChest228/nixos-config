{ config, lib, pkgs, vars, ... }:
{
    powerManagement.enable = true;
    # Hibernate after 30 min with lid closed
    services.logind.settings.Login = {
        HandlePowerKey = "hibernate";
        HandlePowerKeyLongPress = "poweroff";
        HandleLidSwitch = "suspend-then-hibernate"; # Suspend first, then hibernate when the lid is closed
    };
    # Define extra configs for hibernation
    systemd.sleep.extraConfig = '' 
        HibernateMode=shutdown
        HibernateDelaySec=30m
        HibernateState=disk
        SuspendState=mem
    '';
    boot.kernelParams = [ "mem_sleep_default=deep" ];
}
