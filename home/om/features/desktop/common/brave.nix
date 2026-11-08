{pkgs, ...}: {
  programs.brave = {
    enable = true;
    package = pkgs.inputs."brave-nixpkgs".brave;
    extensions = [
      {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # ublock
      {id = "nngceckbapebfimnlniiiahkandclblb";} # bitwarden
    ];
  };
}
