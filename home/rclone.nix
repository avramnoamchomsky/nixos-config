{ ... }:

let
  mountOptions = cacheName: {
    "cache-dir" = "/home/chomsky/.cache/rclone/${cacheName}";
    "dir-cache-time" = "5m";
    "poll-interval" = "0";
    "umask" = "077";
    "vfs-cache-max-age" = "24h";
    "vfs-cache-max-size" = "10Gi";
    "vfs-cache-mode" = "full";
    "vfs-write-back" = "5s";
  };
in
{
  programs.rclone = {
    enable = true;

    remotes = {
      infini-cloud-kurio = {
        config = {
          type = "webdav";
          url = "https://kurio.infini-cloud.net/dav/";
          vendor = "other";
        };
        secrets = {
          user = "/run/secrets/rclone/infini-cloud-kurio-username";
          pass = "/run/secrets/rclone/infini-cloud-kurio-password";
        };

        mounts."" = {
          enable = true;
          mountPoint = "/home/chomsky/mnt/infini-cloud-kurio";
          logLevel = "NOTICE";
          options = mountOptions "infini-cloud-kurio";
        };
      };

      infini-cloud-higa = {
        config = {
          type = "webdav";
          url = "https://higa.teracloud.jp/dav/";
          vendor = "other";
        };
        secrets = {
          user = "/run/secrets/rclone/infini-cloud-higa-username";
          pass = "/run/secrets/rclone/infini-cloud-higa-password";
        };

        mounts."" = {
          enable = true;
          mountPoint = "/home/chomsky/mnt/infini-cloud-higa";
          logLevel = "NOTICE";
          options = mountOptions "infini-cloud-higa";
        };
      };

      aquarius = {
        config = {
          type = "webdav";
          url = "http://aquarius.local:5244/dav";
          vendor = "other";
        };
        secrets = {
          user = "/run/secrets/rclone/aquarius-username";
          pass = "/run/secrets/rclone/aquarius-password";
        };

        mounts."" = {
          enable = true;
          mountPoint = "/home/chomsky/mnt/aquarius";
          logLevel = "NOTICE";
          options = mountOptions "aquarius";
        };
      };
    };
  };

  # Aquarius is a LAN server and may be offline for extended periods. Retry
  # indefinitely at a modest interval instead of entering a tight restart loop.
  systemd.user.services."rclone-mount:@aquarius" = {
    Unit.StartLimitIntervalSec = 0;
    Service.RestartSec = "30s";
  };
}
