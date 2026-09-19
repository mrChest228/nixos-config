{ config, vars, ... }: {
    programs.git = {
        enable = true;
        config = {
            safe.directory = [ vars.configPath ] ++ (builtins.map (user: "/home/" + user + "/cfg") vars.users);
            user = {
                name = "mrChest228";
                email = "gengenm32111111@gmail.com";
            };
            init.defaultBranch = "main";
            pull.rebase = false;
            url."ssh://git@github.com/".insteadOf = "https://github.com/";
        };
    };
    # programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 "
}
