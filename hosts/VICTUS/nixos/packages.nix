{ pkgs, ... }: {
    environment.systemPackages = with pkgs.stable; [
        git
        cudaPackages.cudatoolkit
    ] ++ (with pkgs.unstable; [
        gh

        kitty

        #dmidecode # Gets BIOS and firmware drivers/microcodes info
        #acpica-tools # Tool for fixing bootloading ACPI-bug
        #dracut # Tool to see initrd imported modules
        #pciutils # lspci command

        btrfs-progs # Utility for my FS
        # testing
        acpi # Battery status
        #linuxPackages.cpupower
        lm_sensors # Sensors
        alsa-utils
        # Nvidia drivers
        mesa-demos # Diagnostic tool
        # Security
        #lxqt.lxqt-policykit
        
        # GTK themes for thunar
        adw-gtk3
    ]);
    fonts.packages = with pkgs.unstable; [
    ];
}
