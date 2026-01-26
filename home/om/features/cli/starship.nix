{ config, ... }: let
  colors = config.colorscheme.palette;
  # scheme = "Catppuccin Frappe";
  # base00 = "#303446"; # base
  # base01 = "#292c3c"; # mantle
  # base02 = "#414559"; # surface0
  # base03 = "#51576d"; # surface1
  # base04 = "#626880"; # surface2
  # base05 = "#c6d0f5"; # text
  # base06 = "#f2d5cf"; # rosewater
  # base07 = "#babbf1"; # lavender
  # base08 = "#e78284"; # red
  # base09 = "#ef9f76"; # peach
  # base0A = "#e5c890"; # yellow
  # base0B = "#a6d189"; # green
  # base0C = "#81c8be"; # teal
  # base0D = "#8caaee"; # blue
  # base0E = "#ca9ee6"; # mauve
  # base0F = "#eebebe"; # flamingo
in {
  programs.starship = {
    enable = true;
    settings = {
      format = let
        git = "$git_branch$git_commit$git_state$git_status";
      in ''
        $username$hostname($shlvl)( $cmd_duration) $fill ($nix_shell)''${custom.nix_inspect} ($python)
        $directory(${git}) $fill $time
        $jobs$character
      '';

      fill = {
        symbol = " ";
        disabled = false;
      };

      # Core
      username = {
        format = "[$user]($style)";
        show_always = true;
        style_user = "bold #${colors.base0D}";
        style_root = "bold #${colors.base08}";
      };
      hostname = {
        format = "[@$hostname]($style) ";
        ssh_only = false;
        style = "bold #${colors.base0E}";
      };
      localip = {
        format = "($address) ";
        style = "bold #${colors.base0A}";
        ssh_only = true;
        display_host = false;
      };
      shlvl = {
        disabled = false;
        format = "[$symbol]($style)";
        style = "bold #${colors.base0C}";
        symbol = "❯";
        repeat = true;
        repeat_offset = 0;
        threshold = 1;
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
        style = "bold #${colors.base0A}";
      };
      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
        style = "bold #${colors.base0B}";
      };
      nix_shell = {
        format = "[$symbol($name)]($style) ";
        impure_msg = "";
        style = "bold #${colors.base0C}";
      };
      python = {
        format = "[$symbol$version \\(($virtualenv)\\)]($style) ";
        style = "bold #${colors.base0A}";
      };
      character = {
        error_symbol = "[~~>](bold #${colors.base08})";
        success_symbol = "[->>](bold #${colors.base0B})";
        vimcmd_symbol = "[<<-](bold #${colors.base0A})";
        vimcmd_visual_symbol = "[<<-](bold #${colors.base0C})";
        vimcmd_replace_symbol = "[<<-](bold #${colors.base0D})";
        vimcmd_replace_one_symbol = "[<<-](bold #${colors.base0D})";
      };
      time = {
        format = "\\\[[$time]($style)\\\]";
        disabled = false;
        style = "bold ${colors.base0A}";
      };

      # Cloud
      gcloud = {
        format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
        style = "bold #${colors.base0A}";
      };
      aws = {
        format = "on [$symbol$profile(\\($region\\))]($style)";
        style = "bold #${colors.base0A}";
      };

      # Icon changes only \/
      aws.symbol = " ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elm.symbol = " ";
      elixir.symbol = "";
      gcloud.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      nim.symbol = "󰆥 ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      swift.symbol = "󰛥 ";
      terraform.symbol = "󱁢";
      nix_shell.symbol = " ";
    };
  };
}
