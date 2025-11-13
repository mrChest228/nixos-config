{ config, lib, pkgs, vars, modulesPath, ... }:
{
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot = {
        initrd.availableKernelModules = [ "nvme" "xhci_pci" "uas" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
        kernelModules = [ "kvm-amd" ];
    };
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
