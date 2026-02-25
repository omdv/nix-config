# Factory function for sops secrets
# Usage: mkSecret { name = "backup_passphrase"; sopsFile = ./secrets.yaml; }
{ lib }:
{
  name,
  sopsFile,
  owner ? "om",
  group ? "wheel",
  mode ? "0400",
}:
{
  inherit owner group mode sopsFile;
  path = "/run/user-secrets/${lib.strings.replaceStrings ["_"] ["-"] name}";
}
