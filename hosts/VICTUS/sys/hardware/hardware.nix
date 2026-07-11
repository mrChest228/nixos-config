{ config, lib, pkgs, vars, self, ... }: {
    imports = map (name: self + "/sys/hardware/${name}") [
        # "memory.nix" # TODO
        "amd-integrated.nix"
        "nvidia-prime.nix"
        "power.nix"
    ];
    system.stateVersion = "26.05";
    # Motherboard drivers
    boot.kernelModules = [ "hp_wmi" "wmi_bmof" ];
}
