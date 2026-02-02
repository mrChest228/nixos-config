{ config, libs, lib, pkgs, vars, self, ... }:
{
    home.packages = with pkgs; [
    ] ++ (with pkgs.unstable; [
        # Desktop
        waybar
        swww # Wallpappers
        mako # Notifications
        wl-clipboard # Clipboard
        rofi
        grim # For screenshotes
        slurp # For screenshotes
        pavucontrol # For volume changing
        networkmanagerapplet # For NetManag in a tray (hz)
        # Apps
        xfce.thunar
        kitty
        vivaldi
        btop
    ]);
}
