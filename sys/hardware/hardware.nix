{ config, lib, pkgs, vars, com, cur, get, ... }: {
    imports = get [
        (com + /sys/hardware/amd-integrated.nix)
        (com + /sys/hardware/nvidia-prime.nix)
        (com + /sys/hardware/power.nix)
    ];
    system.stateVersion = "26.05";
    # Motherboard drivers
    boot.kernelModules = [ "hp_wmi" "wmi_bmof" ];
}
