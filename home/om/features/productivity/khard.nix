{pkgs, ...}: {
  home.packages = with pkgs; [khard];
  xdg.configFile."khard/khard.conf".text =
    /*
    toml
    */
    ''
      [general]
      debug = no
      default_action = list
      # These are either strings or comma seperated lists
      editor = nvim, -i, NONE
      merge_editor = diff-so-fancy

      [addressbooks]
      [[contacts]]
      path = ~/.contacts/main
    '';
}
