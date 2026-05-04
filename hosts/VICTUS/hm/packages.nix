{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [
        (self + /hm/packages-fonts.nix) # Import the default HM packages (like fonts, etc.)
    ];
    home.packages = with pkgs; [
    ] ++ (with pkgs.unstable; [
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
    ]);
}
