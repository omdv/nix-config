{
  config,
  pkgs,
  ...
}: {
  # Unkernel mounts the root and supplies the kernel and devices before stage 2.
  boot = {
    kernel.enable = false;
    initrd.enable = false;
    loader.grub.enable = false;
    bootspec.enable = false;
    modprobeConfig.enable = false;
  };
  fileSystems."/" = {
    device = "overlay";
    fsType = "overlay";
    options = ["noauto"];
  };
  system.build.installBootLoader = "${pkgs.coreutils}/bin/true";

  system.build.emulatorInit = pkgs.writeShellScript "emulator-init" ''
    # Unkernel replaces NixOS stage 1; supply its standard devtmpfs links.
    ${pkgs.coreutils}/bin/ln -sfn /proc/self/fd /dev/fd
    ${pkgs.coreutils}/bin/ln -sfn /proc/self/fd/0 /dev/stdin
    ${pkgs.coreutils}/bin/ln -sfn /proc/self/fd/1 /dev/stdout
    ${pkgs.coreutils}/bin/ln -sfn /proc/self/fd/2 /dev/stderr
    exec ${config.system.build.toplevel}/init "$@"
  '';
  services.udev.enable = false;
  services.lvm.enable = false;
  services.timesyncd.enable = false;
  security.audit.enable = false;
  powerManagement.enable = false;
  # hvc0 carries boot diagnostics; the browser opens the only login via a PTY.
  console.enable = false;
  # This file derives limits from the stock ARM kernel, not Unkernel's kernel.
  # Keep Unkernel's ASLR defaults rather than applying incompatible limits.
  environment.etc."sysctl.d/55-nixos-aslr-entropy.conf".enable = false;

  # Seed the ephemeral store database before Home Manager calls Nix.
  # This follows NixOS's SD-image registration service, without a persistent disk.
  systemd.services.register-nix-paths = {
    description = "Register emulator image store paths";
    wantedBy = ["sysinit.target"];
    before = ["sysinit.target" "shutdown.target" "nix-daemon.socket" "nix-daemon.service"];
    after = ["local-fs.target"];
    conflicts = ["shutdown.target"];
    unitConfig.DefaultDependencies = false;
    environment.NIX_REMOTE = "local";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.nix}/bin/nix-store --load-db < /nix-path-registration
      touch /etc/NIXOS
      ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';
  };
  systemd.services.home-manager-om = {
    requires = ["register-nix-paths.service"];
    after = ["register-nix-paths.service"];
  };

  # The bundled Unkernel helper serves its local vsock exec/PTY protocol.
  # Never offer a shell before its declarative home has been activated.
  systemd.services.emulator-terminal = {
    description = "Unkernel terminal transport";
    wantedBy = ["multi-user.target"];
    requires = ["home-manager-om.service"];
    after = ["home-manager-om.service"];
    path = ["/run/current-system/sw" "/usr"];
    environment = {
      HOME = "/home/om";
    };
    serviceConfig = {
      ExecStart = "/usr/bin/kwbox tty serve";
      Restart = "on-failure";
    };
  };
}
