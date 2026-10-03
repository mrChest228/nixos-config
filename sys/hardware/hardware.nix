{ config, lib, com, pkgs, vars, self, ... }: {
    imports = map (name: com.hardware.${name}) [
        "amd-integrated.nix"
        "nvidia-prime.nix"
        "power.nix"
    ];
    system.stateVersion = "26.05";
    # Motherboard drivers
    boot.kernelModules = [ "hp_wmi" "wmi_bmof" ];
}
