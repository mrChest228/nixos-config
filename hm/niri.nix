{ config, lib, pkgs, vars, com, cur, ... }: {
    wayland.windowManager.niri = {
        enable = true;
        settings = {
            binds = {
                "Mod+Return".spawn = "wezterm";
                # niri owns the power key (it holds the logind inhibitor), so the action is bound here, not in logind
                "XF86PowerOff" = {
                    _props.allow-when-locked = true; # _props = KDL node properties in home-manager's toKDL
                    spawn = [ "systemctl" "hibernate" ];
                };
            };
        };
    };
}
