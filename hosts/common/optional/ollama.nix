{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    loadModels = ["qwen3.5"];
  };
}
