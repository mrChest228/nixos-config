{ config, libs, lib, pkgs, vars, self, ... }:
{
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
        fastfetch
        # Benchmarks
        # Sensors
        goverlay
        mangohud
        # psensor
        # system-monitoring-center
        # GPU
        unigine-superposition
        unigine-valley
        # GPU_burn # (CUDA test)
        # CPU
        mprime
        phoronix-test-suite # (ffmpeg, pts/buil2d-kernel, pts/c-ray, pts/cachebench)
        unzip # For ffmpeg
        xmrig
        # systester # (Pi-number)
        # Fonts
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
    ] ++ (with pkgs.unstable; [
    ]);
}
