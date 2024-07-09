{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config.theme = "Dracula";
    themes = {
      dracula = {
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "sublime";
          rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
          sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
        };
        file = "Dracula.tmTheme";
      };
    };
    syntaxes = {
      markdown = {
        src = pkgs.fetchFromGitHub {
          owner = "SublimeText-Markdown";
          repo = "MarkdownEditing";
          rev = "4107-3.1.13";
          hash = "sha256-kW1fKmcwdDl6F4GfWaTFSHj6Pfxj6Yf4aMgBp1OgwVI=";
        };
        file = "syntaxes/Markdown.sublime-syntax";
      };
    };
  };
}
