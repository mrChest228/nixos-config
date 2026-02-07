{ config, pkgs, vars, ... }:
{
    programs = {
        gh.enable = true;
        git = {
            enable = true;
            config = {
                name = "mrChest228";
                email = "gengenm32111111@gmail.com";
            };
        };
    };
}
