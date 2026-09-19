{ config, lib, pkgs, vars, self, ... }: {
    wayland.windowManager.niri = {
        enable = true;
        settings = {
            binds = {
                "Mod+Return".action.spawn = "wezterm";
            };
        };
    };
}
