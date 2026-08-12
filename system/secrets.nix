{ ... }:

{
  sops = {
    defaultSopsFile = ../secrets/webdav.yaml;
    age.keyFile = "/home/chomsky/all_files/secrets/sops-nix/age-key.txt";

    secrets = {
      "rclone/infini-cloud-kurio-username" = {
        owner = "chomsky";
        mode = "0400";
      };

      "rclone/infini-cloud-kurio-password" = {
        owner = "chomsky";
        mode = "0400";
      };

      "rclone/infini-cloud-higa-username" = {
        owner = "chomsky";
        mode = "0400";
      };

      "rclone/infini-cloud-higa-password" = {
        owner = "chomsky";
        mode = "0400";
      };

      "rclone/aquarius-username" = {
        owner = "chomsky";
        mode = "0400";
      };

      "rclone/aquarius-password" = {
        owner = "chomsky";
        mode = "0400";
      };
    };
  };
}
