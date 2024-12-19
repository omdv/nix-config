{ config, ... }: let
  inherit (config.colorscheme) colors harmonized;
in {
  programs.starship = {
    enable = true;
    settings = {
      format = let
        git = "$git_branch$git_commit$git_state$git_status";
        # cloud = "$aws$gcloud$openstack";
      in ''
        $username$hostname($shlvl)($cmd_duration) $fill ($nix_shell)''${custom.nix_inspect}
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
        style_user = "bold ${colors.primary}";
        style_root = "bold ${harmonized.red}";
      };
      hostname = {
        format = "[@$hostname]($style) ";
        ssh_only = false;
        style = "bold ${colors.tertiary}";
      };
      localip = {
        format = "($address) ";
        style = "bold ${harmonized.yellow}";
        ssh_only = true;
        display_host = false;
      };
      shlvl = {
        format = "[$shlvl]($style) ";
        style = "bold ${harmonized.cyan}";
        threshold = 2;
        repeat = true;
        disabled = false;
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
        style = "bold ${harmonized.yellow}";
      };
      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
        style = "bold ${harmonized.green}";
      };
      nix_shell = {
        format = "[($name \\(develop\\) <- )$symbol]($style) ";
        impure_msg = "";
        style = "bold ${harmonized.blue}";
      };
      python = {
        format = "[$symbol$virtual_env]($style) ";
        style = "bold ${harmonized.blue}";
      };
      character = {
        error_symbol = "[~~>](bold ${harmonized.red})";
        success_symbol = "[->>](bold ${harmonized.green})";
        vimcmd_symbol = "[<<-](bold ${harmonized.yellow})";
        vimcmd_visual_symbol = "[<<-](bold ${harmonized.cyan})";
        vimcmd_replace_symbol = "[<<-](bold ${harmonized.magenta})";
        vimcmd_replace_one_symbol = "[<<-](bold ${harmonized.magenta})";
      };
      time = {
        format = "\\\[[$time]($style)\\\]";
        disabled = false;
        style = "bold ${harmonized.yellow}";
      };

      # Cloud
      gcloud = {
        format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
        style = "bold ${harmonized.yellow}";
      };
      aws = {
        format = "on [$symbol$profile(\\($region\\))]($style)";
        style = "bold ${harmonized.yellow}";
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
      shlvl.symbol = "";
      swift.symbol = "󰛥 ";
      terraform.symbol = "󱁢";
      nix_shell.symbol = " ";
    };
  };
}
