{ config, libs, lib, pkgs, vars, ... }:
{
    xdg.userDirs = {
        enable = true;
        createDirectories = true;

        download = "${config.home.homeDirectory}/dwn";
        pictures = "${config.home.homeDirectory}/img"

        # Other files will go to ~
        desktop     = "${config.home.homeDirectory}";
        documents   = "${config.home.homeDirectory}";
        music       = "${config.home.homeDirectory}";
        videous     = "${config.home.homeDirectory}";
        templates   = "${config.home.homeDirectory}";
        publicShare = "${config.home.homeDirectory}";
    }
}
