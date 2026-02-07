{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
    ] ++ (with pkgs.unstable; [
        home-manager # HM command
    ]);
}
