{ pkgs, self, ... }: {
    environment.systemPackages = with pkgs; [
        moreutils # Standart unix utilites needed for bash-scripts
        
        # OCCT benchmark
        (callPackage "${self}/occt.nix" {})
    ] ++ (with pkgs.unstable; [
        home-manager # HM command
        nix-output-monitor
        nix-tree
   
        steam-run # Executing bin files (for /nix/store libs)
        # Nix-ld
        xorg.libICE
        icu
    ]);
}
