{ config, lib, pkgs, ... }: let
    cfg = config.services.nbfc-linux;
in {
    options.services.nbfs-linux = {
        enable = lib.mkEnableOption "NoteBook FanControl service";
        package = lib.mkPackageOption pkgs "nbfc-linux" {};
        profile = lib.mkOption {
            type = lib.types.nullOrStr;
            description = "Name of built-in profile to use. Find your notebook model in https://github.com/nbfc-linux/nbfc-linux/tree/main/share/nbfc/configs (don't copy the \".json\" suffix).";
            default = null;
            example = "ASUS VivoBook X505ZA_X505ZA";
        };
        customProfile = lib.mkOption {
            type = lib.types.nullOr lib.types.deferredAttributeSet;
            description = "Custom nbfc profile in nix, which will be converted to JSON config file";
            default = null;
            example = {
            
            };
        };
        customJSONProfilePath = lib.mkOption {
        };
    };
    environment.etc."nbfc/nbfc.json"

    environment.systemPackages = [ pkgs.nbfc-linux ];
    systemd.services.nbfc = {
        enable = true;
        description = "NoteBook FanControl service";

        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            Type = "simple";
            Restart = "always";
        };

        path = with pkgs; [
            nbfc-linux
            kmod
        ];
        
        script = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file TODO";
    };
}
