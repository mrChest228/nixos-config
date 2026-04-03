{ config, pkgs, vars, ... }:
{
    programs.nushell = {
        enable = true;
        settings = {
            show_banner = false;
        };
        extraConfig = ''
            def returnCode [code: int] {
                run-external "nu" "-c" $"exit ($code)"
            }
            def --env silent [action: closure] {
                let src = (view source $action)
                returnCode (
                    try {
                        let res = (do $action | complete)
                        let code = ($res.exit_code? | default 0)
                        if $code != 0 {
                           print $"($res.stdout)\n(ansi red)($res.stderr)\n(ansi red_bold)Command ($src) FAILED \(exit code ($code)\)(ansi rst)"
                        }
                        $code
                    } catch { |e|
                        print ($e.rendered? | default $e)
                        1
                    }
                )
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
                    git --no-pager log -1 --oneline --format "%C(magenta)%h%C(auto)%d %s"
                    let start = (date now)
                    silent { git push --force-with-lease }
                    print $"(ansi green_bold)Successful push in ((date now) - $start)(ansi rst)"
                }
            }
        '';
        shellAliases = {
            tp = "trash-put";
        };
    };
}
