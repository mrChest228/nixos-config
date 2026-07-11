{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        #dmidecode # Gets BIOS and firmware drivers/microcodes info
        #acpica-tools # Tool for fixing bootloading ACPI-bug
        #dracut # Tool to see initrd imported modules
        #pciutils # lspci command

        # testing
        # acpi # Battery status
        #linuxPackages.cpupower
        lm_sensors # Sensors
        alsa-utils
        # Security
        #lxqt.lxqt-policykit
        
        # GTK themes for thunar
        adw-gtk3

        # Terminal utilities
        btop
        nvtopPackages.full
        # git
        trash-cli
    ] ++ (with pkgs.stable; [
    ]);
    fonts.packages = with pkgs.unstable; [
    ];
}
