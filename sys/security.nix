{ config, lib, pkgs, vars, ... }:
{
    security = {
#         polkit = {
#             enable = true;
#             extraConfig = ''
#                 polkit.addRule((action, subject) => {
#                     if (action.id == "org.freedesktop.policykit.exec") {
#                         return polkit.Result.AUTH_ADMIN;
#                     }
#                 });
#             '';
#         };
        sudo = {
            enable = true;
            extraConfig = ''
                # Enable sudo without password for mrChest
                "mrChest" ALL=(ALL) NOPASSWD: ALL
            '';
        };
    };
}
