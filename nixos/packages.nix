{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        moreutils # Standart unix utilites needed for bash-scripts
    ] ++ (with pkgs.unstable; [
        home-manager # HM command
        nix-output-monitor
        nix-tree
    ]);
}
