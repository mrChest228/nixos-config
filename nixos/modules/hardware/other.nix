{ config, lib, pkgs, vars, modulesPath, ... }:
{
    # All of these settings were copied from hardware-configuration, that's generated for HP Victus 15 fb0028nr (ryzen 7 5800H + nvidia RTX 3050ti) by command "nixos-generate-config"
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = lib.unique ((config.boot.initrd.availableKernelModules or []) ++ [
        "nvme" "xhci_pci" "uas" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
    ]);

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
