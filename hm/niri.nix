{ config, lib, pkgs, vars, com, cur, ... }: {
    wayland.windowManager.niri = {
        enable = true;
        settings = {
            binds = {
                "Mod+Return".spawn = "wezterm";
            };
        };
    };
}
