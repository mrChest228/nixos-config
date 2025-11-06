{ pkgs, vars, ... }:
{
    wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = {
            bind = [
                "SUPER, Q, exec, kitty"
            ];
        };
    };
    # gtk = {
    #     emable = true;
    #     theme = {
    #         name = "adw-gtk3-light";
    #         package = pkgs.gnome.adw-gtk3-theme;
    #     };
    #     iconTheme = {
    #         name = "";
    #         package = "";
    #     };
    #     font = {
    #         name = "";
    #         size = ;
    #     };
    # };
}
