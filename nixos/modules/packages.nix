{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        git

        kitty

        home-manager # Home manager command

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
    ];
    fonts.packages = with pkgs; [
        # Google basic fonts for Hieroglyphs and emoji
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        # Font for coding and other with ligatures
        nerd-fonts.caskaydia-cove
        nerd-fonts.d2coding
        nerd-fonts.fantasque-sans-mono
        nerd-fonts.fira-code
        nerd-fonts.geist-mono
        nerd-fonts.hasklug
        nerd-fonts.iosevka-term-slab
        nerd-fonts.jetbrains-mono

        font-awesome
    ];
    # programs.home-manager.enable = true;
}
