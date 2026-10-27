{
  config,
  lib,
  pkgs,
  ...
}:
import ./mkBorgmaticBackup.nix {inherit config lib pkgs;} {
  repository = "ssh://ylc5axw6@ylc5axw6.repo.borgbase.com/./repo";
  sourceDirectories = [config.home.homeDirectory];
  frequency = "*-*-* *:00/6:00";
}
