{pkgs, ...}: let
  strix-podman = pkgs.writeShellScriptBin "strix" ''
    export DOCKER_HOST="''${DOCKER_HOST:-unix://''${XDG_RUNTIME_DIR:?}/podman/podman.sock}"
    exec ${pkgs.strix}/bin/strix "$@"
  '';
in {
  home.packages = [strix-podman];

  programs.fish.functions.strix = ''
    set -lx STRIX_LLM openrouter/~deepseek/deepseek-pro-latest
    set -lx LLM_API_KEY (pass show llm/openrouter/general-key)
    or return 1

    command strix $argv
  '';

  systemd.user.sockets.podman = {
    Unit = {
      Description = "Podman API Socket";
      Documentation = "man:podman-system-service(1)";
    };
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install.WantedBy = ["sockets.target"];
  };
}
