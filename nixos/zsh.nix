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
    #                 sudo nixos-rebuild switch --flake .#${vars.user} && \
    #                 home-manager switch --flake .#${vars.user}
    #             )
    #         '';
    #         rebuild = ''
    #             (
    #                 cd /etc/nixos && \
    #                 sudo nixos-rebuild switch --flake .#${vars.user} && \
    #                 home-manager switch --flake .#${vars.user}
    #             )
    #         '';
    #         reconf = "home-manager switch --flake /etc/nixos#${vars.user}";
    #     };
    #     ohMyZsh = {
    #         enable = true;
    #         # plugins = [];
    #         # theme = "";
    #     };
    };
    users.defaultUserShell = pkgs.unstable.zsh;
    environment.shells = [ pkgs.unstable.zsh ];
}
