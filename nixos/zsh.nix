{ config, lib, pkgs, vars, ... }:
{
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.unstable.zsh;
    environment.shells = [ pkgs.unstable.zsh ];
}
