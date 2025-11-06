{ config, lib, pkgs, vars, ... }:
{
    programs = {
        hyprland = {
            enable = true;
            withUWSM = true;
        };
    };
}
