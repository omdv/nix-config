{
  services.picom = {
    enable = true;
    activeOpacity = 1.0;
    inactiveOpacity = 1.0;
    fade = true;
    fadeSteps = [ 0.028 0.03 ] ;
    backend = "glx";
    opacityRules = [
      "90:class_g = 'kitty'"
    ];
  };
}
