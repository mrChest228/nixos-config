{ config, libs, lib, pkgs, vars, self, ... }:
{
    home.packages = with pkgs; [
        git
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
        thunar
        kitty
        firefox
        btop
    ]); #++ (import (self + /home-manager/packages.nix) { inherit pkgs; }); # Import the default HM packages (like git, trash-cli, etc.)
}
