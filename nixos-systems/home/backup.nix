{ config, ... }:
{
  sops.secrets.restic_backup_key = { };
  sops.secrets.backblaze_env_file = { };

  services.restic = {
    enable = true;
    backups.remotebackup = {
      environmentFile = "${config.sops.secrets.backblaze_env_file.path}";
      passwordFile = "${config.sops.secrets.restic_backup_key.path}";
      paths = [
        "/home/data/sync/"
      ];
      inhibitsSleep = true;
      initialize = true;
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 3"
        "--keep-yearly 2"
      ];
      repository = "b2:tyx-backup:/backup";
      timerConfig = {
        OnCalendar = "23:42";
        RandomizedDelaySec = "10m";
      };
    };
  };
}
