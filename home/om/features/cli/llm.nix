{ pkgs, ... }: {
  home.packages = with pkgs; [
    aichat
    llm
    litellm
    shell-gpt
  ];
}
