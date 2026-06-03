{ config, lib, pkgs, vars, self, ... }: {
    programs.niri = {
        enable = true;
        settings = {
            binds = {
                "Mod+Return".action.spawn = "wezterm";
            };
        };
    };
}
