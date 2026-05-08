{ pkgs, self, ... }: {
    environment.systemPackages = with pkgs; [
        home-manager # HM command
        nix-output-monitor
        nix-tree
        moreutils # Standart unix utilites needed for bash-scripts
    ] ++ (with pkgs.stable; [
    ]);
}
