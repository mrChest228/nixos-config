{ config, pkgs, vars, ... }:
{
    imports = [
        ./modules/hyprland.nix
        ./modules/packages.nix
        ./modules/zsh.nix
    ];
    home = {
        username = vars.userName;
        homeDirectory = "/home/${vars.userName}";
        stateVersion = vars.systemVersion;
    };
}
