{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # defaultOptions reloads only with restart
    defaultOptions = [
      "--inline-info"
      "--color 16"
      "--height 100%"
      "--preview 'bat --color=always {}'"
    ];
  };
}
