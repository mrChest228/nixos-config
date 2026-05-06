{ config, lib, pkgs, vars, ... }:
{
    programs.hyprland = {
        enable = true;
        package = pkgs.hyprland;
        withUWSM = true;
    };
}
