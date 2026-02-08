{ pkgs-unstable, ... }: {
  home.packages = with pkgs-unstable; [
    aichat
    llm
    litellm
    shell-gpt
  ];
}
