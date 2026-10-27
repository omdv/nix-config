{
  config,
  lib,
  pkgs,
  ...
}:
import ./mkBorgmaticBackup.nix {inherit config lib pkgs;} {
  repository = "ssh://nnyrw2md@nnyrw2md.repo.borgbase.com/./repo";
  sourceDirectories = [
    config.home.homeDirectory
    "/pool/media"
    "/pool/databases"
  ];
  frequency = "daily";
}
