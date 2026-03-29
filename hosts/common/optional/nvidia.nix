{
  config,
  pkgs,
  ...
}: {
  # Ensure the proprietary NVIDIA driver, not nouveau, binds the GPU
  boot.blacklistedKernelModules = ["nouveau"];

  # Graphics stack
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # useful for Steam / 32-bit apps (safe to keep)
  };

  # Tell X/Wayland stack to use NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # GTX 1080 (Pascal) -> use proprietary kernel module
    open = false;

    # Required for most modern desktop setups
    modesetting.enable = true;

    # Power management defaults (safe)
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # NVIDIA settings utility
    nvidiaSettings = true;

    # Match driver package to current kernel
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Optional: tools for debugging / verification
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    vulkan-tools
    mesa-demos
  ];
}
