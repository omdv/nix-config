{inputs, ...}: {
  imports = [inputs.paseo.nixosModules.default];

  services.paseo = {
    enable = true;
    user = "om";
    group = "users";
    inheritUserEnvironment = true;

    listenAddress = "127.0.0.1";
    port = 6767;
    openFirewall = false;

    relay.enable = true;
  };
}
