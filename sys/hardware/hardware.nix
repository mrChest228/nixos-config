{ config, lib, pkgs, vars, com, cur, ... }: {
    imports = map (name: com + "/sys/hardware/${name}") [
        "amd-integrated.nix"
        "nvidia-prime.nix"
        "power.nix"
    ];
    system.stateVersion = "26.05";
    # Motherboard drivers
    boot.kernelModules = [ "hp_wmi" "wmi_bmof" ];
}
