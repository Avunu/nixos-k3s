{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.juicefs;
in
{
  options.services.juicefs = {
    enable = mkEnableOption "JuiceFS distributed file system";

    filesystems = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          metaUrl = mkOption {
            type = types.str;
            description = "JuiceFS metadata storage URL";
            example = "redis://localhost:6379/1";
          };

          storage = mkOption {
            type = types.str;
            description = "Object storage type";
            default = "s3";
            example = "s3";
          };

          bucket = mkOption {
            type = types.str;
            description = "Object storage bucket name";
            example = "my-juicefs-bucket";
          };

          accessKey = mkOption {
            type = types.nullOr types.str;
            description = "Object storage access key";
            default = null;
          };

          secretKey = mkOption {
            type = types.nullOr types.str;
            description = "Object storage secret key";
            default = null;
          };

          endpoint = mkOption {
            type = types.nullOr types.str;
            description = "Object storage endpoint URL";
            default = null;
            example = "https://s3.gra.io.cloud.ovh.net";
          };

          mountPoint = mkOption {
            type = types.str;
            description = "Mount point for the JuiceFS filesystem";
            example = "/mnt/juicefs";
          };

          formatOnce = mkOption {
            type = types.bool;
            description = "Whether to format the filesystem on first start";
            default = false;
          };

          mountOptions = mkOption {
            type = types.listOf types.str;
            description = "Additional mount options for JuiceFS";
            default = [];
            example = ["--cache-dir=/var/cache/juicefs" "--cache-size=1024"];
          };

          accessKeyFile = mkOption {
            type = types.nullOr types.path;
            description = "Path to file containing object storage access key";
            default = null;
          };

          secretKeyFile = mkOption {
            type = types.nullOr types.path;
            description = "Path to file containing object storage secret key";
            default = null;
          };

          environmentFile = mkOption {
            type = types.nullOr types.path;
            description = "Path to environment file containing JuiceFS configuration";
            default = null;
            example = "/etc/juicefs/config";
          };
        };
      });
      default = {};
      description = "JuiceFS filesystems to configure";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      juicefs
    ];

    systemd.services = mapAttrs' (name: fs: nameValuePair "juicefs-${name}" {
      description = "JuiceFS filesystem ${name}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = mkMerge [
        (mkIf (fs.accessKey != null) { ACCESS_KEY = fs.accessKey; })
        (mkIf (fs.secretKey != null) { SECRET_KEY = fs.secretKey; })
      ];

      serviceConfig = {
        Type = "forking";
        EnvironmentFile = optional (fs.environmentFile != null) fs.environmentFile;
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${fs.mountPoint}"
          "${pkgs.coreutils}/bin/mkdir -p /var/cache/juicefs"
        ] ++ optional fs.formatOnce 
          "${pkgs.juicefs}/bin/juicefs format ${optionalString (fs.storage != null) "--storage ${fs.storage}"} ${optionalString (fs.bucket != null) "--bucket ${fs.bucket}"} ${optionalString (fs.endpoint != null) "--endpoint ${fs.endpoint}"} ${fs.metaUrl} ${name}"
        ++ optional (fs.accessKeyFile != null)
          "${pkgs.coreutils}/bin/export ACCESS_KEY=$(${pkgs.coreutils}/bin/cat ${fs.accessKeyFile})"
        ++ optional (fs.secretKeyFile != null)
          "${pkgs.coreutils}/bin/export SECRET_KEY=$(${pkgs.coreutils}/bin/cat ${fs.secretKeyFile})";
        
        ExecStart = "${pkgs.juicefs}/bin/juicefs mount ${fs.metaUrl} ${fs.mountPoint} ${concatStringsSep " " fs.mountOptions} --background";
        ExecStop = "${pkgs.util-linux}/bin/umount ${fs.mountPoint}";
        RemainAfterExit = true;
        RestartSec = 5;
        Restart = "on-failure";
      };
    }) cfg.filesystems;

    # Ensure mount points are created
    systemd.tmpfiles.rules = mapAttrsToList (name: fs: 
      "d ${fs.mountPoint} 0755 root root -"
    ) cfg.filesystems;
  };
}