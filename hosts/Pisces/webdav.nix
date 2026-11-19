{ username }:
{ config, lib, ... }:

let
  homeDirectory = config.users.users.${username}.home;
  remotes = [
    {
      name = "infini-cloud-kurio";
      url = "https://kurio.infini-cloud.net/dav/";
    }
    {
      name = "infini-cloud-higa";
      url = "https://higa.teracloud.jp/dav/";
    }
  ];
  mountPoint = name: "${homeDirectory}/mnt/${name}";
  secretName = name: field: "rclone/${name}-${field}";
in
{
  sops.age.keyFile = "${homeDirectory}/all_files/secrets/sops-nix/age-key.txt";
  sops.secrets = lib.listToAttrs (
    lib.concatMap ({ name, ... }: map (field: lib.nameValuePair (secretName name field) {
      sopsFile = ../../secrets/webdav.yaml;
      owner = username;
      mode = "0400";
    }) [ "username" "password" ]) remotes
  );

  # Home Manager mounts these remotes. The fstab entries keep GVfs from
  # probing them when a local file dialog opens.
  environment.etc.fstab.text = lib.mkAfter (
    lib.concatMapStrings ({ name, ... }: ''
      ${name}: ${mountPoint name} fuse.rclone noauto,nofail,x-gvfs-hide 0 0
    '') remotes
  );

  home-manager.users.${username}.programs.rclone = {
    enable = true;
    remotes = lib.listToAttrs (map ({ name, url }: lib.nameValuePair name {
      config = {
        type = "webdav";
        inherit url;
        vendor = "other";
      };
      secrets = {
        user = config.sops.secrets.${secretName name "username"}.path;
        pass = config.sops.secrets.${secretName name "password"}.path;
      };
      mounts."" = {
        enable = true;
        mountPoint = mountPoint name;
        logLevel = "NOTICE";
        options = {
          "cache-dir" = "${homeDirectory}/.cache/rclone/${name}";
          "dir-cache-time" = "5m";
          "poll-interval" = "0";
          "umask" = "077";
          "vfs-cache-max-age" = "24h";
          "vfs-cache-max-size" = "10Gi";
          "vfs-cache-mode" = "full";
          "vfs-write-back" = "5s";
        };
      };
    }) remotes);
  };
}
