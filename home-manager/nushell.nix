{ config, pkgs, vars, ... }:
{
    programs.nushell = {
        enable = true;
        settings = {
            show_banner = false;
        };
        extraConfig = ''
            # Datetime format
            $env.config.datetime_format = {
                table: '%Y-%m-%d %H:%M:%S'
            }

            def returnCode [code: int] {
                run-external "nu" "-c" $"exit ($code)"
            }
            def --env silent [action: closure] {
                let src = (view source $action)
                returnCode (
                    try {
                        let res = (do $action | complete)
                        if $res.exit_code != 0 {
                           print $"($res.stdout)\n(ansi red)($res.stderr)\n(ansi red_bold)Command ($src) FAILED \(exit code ($res.exit_code)\)(ansi rst)"
                        }
                        $res.exit_code
                    } catch { |e|
                        print ($e.rendered? | default $e)
                        1
                    }
                )
            }
            def --wrapped nudo [...rest: string] {
                if ($rest | is-empty) { return }
                
                mut nwRest = ($rest | each { |s|
                    if ($s | str contains " ") { $"\"($s)\"" } else { $s }
                })
                $nwRest.0 = ($nwRest.0 | str replace '^"|"$' ''') # Remove " from the start and the end of command name

                let cmd = ($rest | str join " ")

                let res = (sudo nu --config /home/${vars.user}/.config/nushell/config.nu --env-config /home/${vars.user}/.config/nushell/env.nu -c $"($cmd) | to nuon" | complete)
                if $res.exit_code != 0 {
                    $"($res.stdout)\n(ansi red)($res.stderr)\n(ansi red_bold)Command ($cmd) FAILED \(exit code ($res.exit_code)\)(ansi rst)"
                } else {
                    ($res.stdout | from nuon)
                }
            }
            def config-commit [message?: string] {
                cd ${vars.configPath}
                git add .
                let push = (
                    if not ((git status -s) | is-empty) {
                        echo "File changes:"
                        git status -s
                        let msg = if ($message | is-empty) { $"Commit (date now | format date '%Y-%m-%d %H:%M:%S %:z')" } else { $message }
                        silent { git commit -m $"($msg)" }
                        true
                    } else {
                        print $"(ansi cyan)Nothing to commit(ansi rst)"
                        if (not ($message | is-empty) and ($message != (git log -1 --format=%s))) {
                            let reply = (input "Do you want to rename the last commit? [Y/n]: " | str downcase)
                            if ($reply == "" or $reply == "y" or $reply == "ye" or $reply == "yes") {
                                silent { git commit --amend -m $"($message)" }
                                true
                            } else { false }
                        } else { false }
                    }
                )
                if $push {
                    git --no-pager log -1 --oneline --format="%C(magenta)%h%C(auto)%d %s"
                    let start = (date now)
                    silent { git push --force-with-lease }
                    print $"(ansi green_bold)Successful push in ((date now) - $start)(ansi rst)"
                }
            }
            def update [message?: string] {
                cd ${vars.configPath}
                nix flake update
                if (not ((git status -s) | is-empty) or not ($message | is-empty)) {
                    try { config-commit (if ($message | is-empty) { $"Update (date now | format date '%Y-%m-%d %H:%M:%S %:z')" } else { $message }) }
                }
                rebuild
            }
            def rebuild [message?: string] {
                cd ${vars.configPath}
                if (not ((git status -s) | is-empty) or not ($message | is-empty)) {
                    try { config-commit (if ($message | is-empty) { $"Rebuild (date now | format date '%Y-%m-%d %H:%M:%S %:z')" } else { $message }) }
                }

                let bootedGen = (readlink -f /run/current-system)
                let prvGen = (readlink -f /nix/var/nix/profiles/system)

                nh os switch
                nh home switch

                let newGen = (readlink -f /nix/var/nix/profiles/system)
                if (($prvGen != $bootedGen) and ($prvGen != $newGen)) {
                    let prvLinks = ((nudo ls -l /nix/var/nix/profiles/system-*-link) | where target == $prvGen)
                    if (($prvLinks | length) == 1) {
                        gen del ($prvLinks.0.name | str replace -a -r '\D' ''')
                    }
                }

                gen clean
            }
            def reconf [message?: string] {
                cd ${vars.configPath}
                if (not ((git status -s) | is-empty) or not ($message | is-empty)) {
                    try { config-commit (if ($message | is-empty) { $"Reconf (date now | format date '%Y-%m-%d %H:%M:%S %:z')" } else { $message }) }
                }
                nh home switch

                gen clean
            }

            def "gen del" [...ids: string] {
                sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations ($ids | str join " ")
                sudo /run/current-system/bin/switch-to-configuration boot
            }
            def "gen switch" [id: any] {
                sudo $"/nix/var/nix/profiles/system-($id)-link/bin/switch-to-configuration" switch
            }
            def "gen clean" [] {
                nh clean all --keep 3 --keep-since 3d --nogc --nogcroots
                sudo /run/current-system/bin/switch-to-configuration boot
            }
        '';
        shellAliases = {
            tp = "trash-put";

            "gen list" = "nh os info";
            "gen-ls" = "nixos-rebuild list-generations";
        };
    };
}
