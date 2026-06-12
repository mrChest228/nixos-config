{ config, lib, pkgs, vars, self, ... }: {
    imports = map (name: self + "/sys/hardware/${name}") [
        # "memory.nix" # TODO
        "amd-integrated.nix"
        "nvidia-prime.nix"
    ];
    system.stateVersion = "25.11";
    # Motherboard drivers
    boot.kernelModules = [ "hp_wmi" "wmi_bmof" ];
    programs.coolercontrol.enable = true; # Graphical utility to see the sensor values # TODO: delete if it's unusefuls
}
