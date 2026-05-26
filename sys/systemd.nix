{
    systemd.settings.Manager = {
        DefaultTimeoutStopSec = "30s"; # Services stopping timer before killing during shutting down
        DefaultTimeoutStartSec = "30s";
    };
}
