{ config, lib, pkgs, vars, ... }:
{
    services.greetd = {
        enable = true;
        settings = {
            initial_session = {
                user = vars.user;
                command = "hyprland";
            };
            default_session = {
                user = vars.user;
                command = "zsh";
            };
        };
    };
}
