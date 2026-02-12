{ pkgs, ... }: {
  programs.brave = {
    enable = true;
    package = pkgs.unstable.brave;
    extensions = [
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
    ];
  };
}
