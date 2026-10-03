{ config, lib, com, pkgs, vars, self, ... }: {
    environment.systemPackages = with pkgs; [
        #dmidecode # Gets BIOS and firmware drivers/microcodes info
        #acpica-tools # Tool for fixing bootloading ACPI-bug
        #dracut # Tool to see initrd imported modules
        #pciutils # lspci command

        # testing
        #linuxPackages.cpupower
        alsa-utils
        # Security
        #lxqt.lxqt-policykit
        
        # GTK themes for thunar
        adw-gtk3

        # Terminal utilities
        btop-cuda
        nvtopPackages.full
        # git
        trash-cli
    ] ++ (with pkgs.stable; [
    ]);
    fonts.packages = with pkgs.unstable; [
    ];
}
