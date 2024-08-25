{ lib, config, ... }:
  let hostName = builtins.getEnv "HOSTNAME";
in {
  programs.ssh = {
    enable = true;
  };

  home.activation = {
    generateSSHKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "${config.home.username}@${hostName}";
      fi
    '';
  };
}
