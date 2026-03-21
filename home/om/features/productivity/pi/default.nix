{ ... }: {
  # Deploy extensions to PI agent (standard pi-coding-agent)
  # Extensions directory: ~/.config/pi/extensions/
  
  # Security extension - blocks dangerous commands and protects sensitive files
  home.file.".config/pi/extensions/security/index.ts".source =
    ./extensions/security/index.ts;
  
  # Add more extensions here:
  # home.file.".config/pi/extensions/another/index.ts".source =
  #   ./extensions/another/index.ts;
}
