{pkgs, ...}: {
  home.packages = with pkgs.inputs.claude-desktop; [
    claude-desktop
  ];
}
