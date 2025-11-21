{ pkgs, vars, ... }:
{
    home.packages = with pkgs; [
        # CUDA
        cudaPackages.cudatoolkit
        # Desktop
        waybar
        swww # Wallpappers
        mako # Notifications
        wl-clipboard # Clipboard
        wofi
        grim # For screenshotes
        slurp # For screenshotes too
        pavucontrol # For volume changing
        networkmanagerapplet # For NetMan in a tray (hz)
        # Apps
        xfce.thunar
        # kitty
        stable.htop

        vivaldi
        btop
    ];
}
