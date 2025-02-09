{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ sshfs ];

  fileSystems."/mnt/sshfs" = {
    device = "om@192.168.1.98:/home/om/nix-config";
    fsType = "sshfs";
    options = [
      "debug"
      "allow_other"
      "IdentityFile=/home/om/.ssh/id_rsa"
    ];
};
}
