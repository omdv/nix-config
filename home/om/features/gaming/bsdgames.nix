{ pkgs, ... }: {
home.packages = with pkgs; [
  fish
  (pkgs.runCommand "bsd-games-renamed" {} ''
    mkdir -p $out/bin $out/share
    cp -r ${pkgs.bsdgames}/bin/* $out/bin/
    cp -r ${pkgs.bsdgames}/share/* $out/share/
    mv $out/bin/fish $out/bin/bsd-fish
    '')
  ];
}
