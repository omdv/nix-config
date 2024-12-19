{ config, ... }: let
  # inherit (config.colorscheme) colors harmonized;
  colors = {
    "background"= "#121318";
    "error"= "#ffb4ab";
    "error_container"= "#93000a";
    "inverse_on_surface"= "#303036";
    "inverse_primary"= "#4f5b92";
    "inverse_surface"= "#e3e1e9";
    "on_background"= "#e3e1e9";
    "on_error"= "#690005";
    "on_error_container"= "#ffdad6";
    "on_primary"= "#202c61";
    "on_primary_container"= "#dde1ff";
    "on_primary_fixed"= "#07164b";
    "on_primary_fixed_variant"= "#374379";
    "on_secondary"= "#2c2f42";
    "on_secondary_container"= "#dfe1f9";
    "on_secondary_fixed"= "#171b2c";
    "on_secondary_fixed_variant"= "#424659";
    "on_surface"= "#e3e1e9";
    "on_surface_variant"= "#c6c5d0";
    "on_tertiary"= "#44273e";
    "on_tertiary_container"= "#ffd7f3";
    "on_tertiary_fixed"= "#2c1229";
    "on_tertiary_fixed_variant"= "#5c3d56";
    "outline"= "#90909a";
    "outline_variant"= "#45464f";
    "primary"= "#b8c3ff";
    "primary_container"= "#374379";
    "primary_fixed"= "#dde1ff";
    "primary_fixed_dim"= "#b8c3ff";
    "scrim"= "#000000";
    "secondary"= "#c3c5dd";
    "secondary_container"= "#c3c5dd";
    "secondary_fixed"= "#dfe1f9";
    "secondary_fixed_dim"= "#c3c5dd";
    "shadow"= "#000000";
    "surface"= "#121318";
    "surface_bright"= "#38393f";
    "surface_container"= "#1f1f25";
    "surface_container_high"= "#292a2f";
    "surface_container_highest"= "#34343a";
    "surface_container_low"= "#1b1b21";
    "surface_container_lowest"= "#0d0e13";
    "surface_dim"= "#121318";
    "surface_variant"= "#45464f";
    "tertiary"= "#e4bad9";
    "tertiary_container"= "#5c3d56";
    "tertiary_fixed"= "#ffd7f3";
    "tertiary_fixed_dim"= "#e4bad9";
  };
  harmonized = {
    red = "#ff0000";
    green = "#00ff00";
    blue = "#0000ff";
    yellow = "#ffff00";
    orange = "#ffa500";
    purple = "#800080";
    pink = "#ffc0cb";
    brown = "#a52a2a";
    gray = "#808080";
    magenta = "#ff00ff";
    cyan = "#00ffff";
  } //colors;
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
