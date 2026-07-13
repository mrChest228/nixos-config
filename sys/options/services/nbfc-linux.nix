{ config, lib, pkgs, ... }: 
let
    cfg = config.services.nbfc-linux;
    jsonFormat = pkgs.formats.json {};
in {
    options.services.nbfc-linux = {
        enable = lib.mkEnableOption "NoteBook FanControl service";

        package = lib.mkPackageOption pkgs "nbfc-linux" {};

        settings = {
            profile = lib.mkOption {
                type = lib.types.str;
                default = null;
                description = "Name of built-in profile to use. Find your notebook model in https://github.com/nbfc-linux/nbfc-linux/tree/main/share/nbfc/configs (without \".json\").";
                example = "ASUS VivoBook X505ZA_X505ZA";
            };
            extraProfiles = lib.mkOption {
                type = lib.types.attrsOf (lib.types.oneOf (with lib.types; [
                    path
                    str
                    jsonFormat.type
                ]));
                default = {};
                description = "An attribute set of additional nbfc profiles. It can be either path to nix/json file or just a nix attr list";
                example = lib.literalExpression ''
                    {
                        "My laptop" = ./configs/my-laptop.nix # TODO: JSON and Nix
                        "Your laptop" = "/etc/nixos/your-laptop.json"
                        "Another laptop" = { # TODO: make Laptop model the same as the NotebookModel
                            EcPollInterbal = 3000;
                            CriticalTemperature = 90;
                        };
                    }
                '';
            };
            profileSettingsOverrides = lib.mkOption {
                type = lib.types.listOf (lib.types.functionTo jsonFormat.type);
                default = {};
                description = "A set of settings which will be added and overrided in selected profile";
                example = lib.literalExpression ''
                    [
                        (prev: {
                            CriticalTemperature = 90;
                            FanConfigurations = []; # TODO
                        })
                    ]
                '';
            };
        };
    };

    config = lib.mkIf cfg.enable (let
        configJson = pkgs.writeText "nbfc-config.json" (builtins.toJSON { SelectedConfigId = "/etc/nixos/host/sys/hardware/nbfc-VICTUS.json" /*cfg.settings.profile*/; });
    in {
        environment.etc."nbfc/nbfc.json".source = configJson;

        environment.systemPackages = [ pkgs.nbfc-linux ];
        systemd.services.nbfc = {
            enable = true;
            description = "NoteBook FanControl service";

            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                Type = "simple";
                Restart = "on-failure";
            };
            restartTriggers = [ "${configJson}" ];

            path = with pkgs; [
                nbfc-linux
                kmod
            ];

            script = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file /etc/nbfc/nbfc.json";
        };
    });
}
