{ lib, config, ... }:
{
  programs.ssh = {
    enable = true;
  };

  home.activation = {
    generateSSHKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "${config.users.users.om}@${config.networking.hostname}";
      fi
    '';
  };
}
