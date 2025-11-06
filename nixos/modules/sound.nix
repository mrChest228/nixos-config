{ config, lib, pkgs, vars, ... }:
{
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
    };
}
