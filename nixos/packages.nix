{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
    ] ++ (with pkgs.unstable; [
        home-manager # HM command
    ]);
    fonts.packages = with pkgs.unstable; [
        # Google basic fonts for Hieroglyphs and emoji
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
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
