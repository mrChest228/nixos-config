{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [
        (self + /home-manager/packages-fonts.nix) # Import the default HM packages (like git, trash-cli, etc.)
    ];
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
        thunar
        kitty
        firefox
        btop
    ]);
}
