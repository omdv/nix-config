{ config, ... }: {
  # move all scripts from scripts folder
  home.file."${config.xdg.configHome}/i3/scripts" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };
}
