{ pkgs, ... }: {
    environment.systemPackages = with pkgs.stable; [
        home-manager # Home manager command
        cudaPackages.cudatoolkit
    ] ++ (with pkgs; []);
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
}
