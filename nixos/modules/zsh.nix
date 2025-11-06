{ config, lib, pkgs, vars, ... }:
{
    programs.zsh = {
        enable = true;
    #     enableCompletion = true;
    #     autosuggestions.enable = true;
    #     syntaxHighlighting.enable = true;
    #     histSize = 10000;
    #     shellAliases = {
    #         update = ''
    #             (
    #                 cd /etc/nixos && \
    #                 sudo nix flake update && \
    #                 sudo nixos-rebuild switch --flake .#${vars.userName} && \
    #                 home-manager switch --flake .#${vars.userName}
    #             )
    #         '';
    #         rebuild = ''
    #             (
    #                 cd /etc/nixos && \
    #                 sudo nixos-rebuild switch --flake .#${vars.userName} && \
    #                 home-manager switch --flake .#${vars.userName}
    #             )
    #         '';
    #         reconf = "home-manager switch --flake /etc/nixos#${vars.userName}";
    #     };
    #     ohMyZsh = {
    #         enable = true;
    #         # plugins = [];
    #         # theme = "";
    #     };
    };
    users.defaultUserShell = pkgs.zsh;
    environment.shells = [ pkgs.zsh ];
}
