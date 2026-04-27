{ config, lib, pkgs, vars, ... }:
{
    programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
        withUWSM = true;
    };
}
