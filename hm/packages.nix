{ config, lib, com, pkgs, vars, self, ... }:
{
    imports = [
        com."packages+fonts.nix" # Import the default HM packages (like fonts, etc.)
    ];
    home.packages = with pkgs; [
        # Desktop
        waybar
        # Wallpapers
        awww
        mpvpaper
        mako # Notifications
        wl-clipboard # Clipboard
        rofi
        grim # For screenshotes
        slurp # For screenshotes
        pavucontrol # For volume changing
        networkmanagerapplet # For NetManag in a tray (hz)
        # Apps
        thunar
        ghostty
        wezterm
        firefox
        
        telegram-desktop
    ] ++ (with pkgs.stable; [
    ]);
}
