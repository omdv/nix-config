{pkgs, ...}: let
  mirageWrapper = pkgs.writeShellScriptBin "mirage-proxy-wrapped" ''
    set -euo pipefail
    # Retrieve vault key from pass
    export MIRAGE_VAULT_KEY=$(${pkgs.pass}/bin/pass mirage/vault-key 2>/dev/null || true)
    exec ${pkgs.mirage-proxy}/bin/mirage-proxy "$@"
  '';
in {
  # home.packages = [
  #   mirageWrapper
  # ];

  # config file
  home.file.".config/mirage/mirage.yaml".text = ''
    sensitivity: medium   # low | medium | high | paranoid

    bypass:
      - "generativelanguage.googleapis.com"  # skip Google (TLS fingerprint issues)

    rules:
      always_redact: [SSN, CREDIT_CARD, PRIVATE_KEY, AWS_KEY, GITHUB_TOKEN, SECRET]
      mask: [EMAIL, PHONE]
      warn_only: [IP_ADDRESS]

    audit:
      enabled: true
      path: "./mirage-audit.jsonl"
      log_values: false
  '';

  # # systemd service
  # systemd.user.services.mirage-proxy = {
  #   Unit = {
  #     Description = "Mirage proxy daemon";
  #     After = ["network-online.target"];
  #     Wants = ["network-online.target"];
  #   };

  #   Service = {
  #     Type = "simple";
  #     StateDirectory = "mirage";
  #     WorkingDirectory = "%S/mirage";
  #     ExecStart = "${mirageWrapper}/bin/mirage-proxy-wrapped --port 8686 --no-update-check --config %E/mirage/mirage.yaml";
  #     Restart = "always";
  #     RestartSec = 2;
  #   };

  #   Install = {
  #     WantedBy = ["default.target"];
  #   };
  # };
}
