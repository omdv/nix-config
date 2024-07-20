{ pkgs, config, ... }: {
  home.pointerCursor =
    let
      getFrom = url: hash: name: {
          gtk.enable = false;
          x11.enable = false;
          name = name;
          size = config.i3scaling.cursorSize;
          package =
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom
        # https://www.pling.com/browse?cat=107&ord=latest
        # nix-prefetch-url --unpack and then nix hash to-sri --type sha256 <hash>
        "https://gitlab.com/-/project/6703061/uploads/0a4231d25cdd465b9441f7c64e11f33e/Hackneyed-Dark-0.9.2-right-handed.tar.bz2"
        "sha256-8IUQbze5Cuyx84p/m6V4KZgwfjgpYXr0UfLlok/Oszs="
        "Hackneyed";
}
