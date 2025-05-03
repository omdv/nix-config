{ pkgs, ... }: {
  home.packages = with pkgs; [
    ffmpeg
    mpg123
  ];
}
