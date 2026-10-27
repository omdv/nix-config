{
  lib,
  config,
  hostName,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  home.activation = {
    sshDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
    '';

    generateSSHKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ~/.ssh/id_rsa ]; then
        /run/current-system/sw/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -N "" -C "${config.home.username}@${hostName}";
      fi
    '';
  };
}
