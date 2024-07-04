{
  pkgs,
  lib,
  ...
}: {

# # add newline between prompts
# add_newline = true

# # define format
# format = """
# $directory\
# $git_branch\
# $git_status\
# $cmd_duration\
# $character
# """

# # right format
# right_format = """
# $python\
# $rust
# """

# [character]
# error_symbol = "[λ](bold #ff5555)"
# success_symbol = "[λ](bold #50fa7b)"

# [cmd_duration]
# format = 'took [$duration]($style) '
# style = "bold #f1fa8c"
# min_time = 100

# [directory]
# truncation_length = 3
# truncation_symbol = '…/'
# truncate_to_repo = false
# read_only = '🔒'
# style = "bold #50fa7b"

# [direnv]
# disabled = false

# [git_branch]
# style = "bold #ff79c6"

# [git_status]
# style = "bold #ff5555"

# [hostname]
# style = "bold #bd93f9"

# [username]
# format = "[$user]($style) on "
# style_user = "bold #8be9fd"

  programs.starship = {
    enable = true;
    settings = {
      format = let
        git = "$git_branch$git_commit$git_state$git_status";
        cloud = "$aws$gcloud$openstack";
      in ''
        $username$hostname($shlvl)($cmd_duration) $fill ($nix_shell)''${custom.nix_inspect}
        $directory(${git})(${cloud})(''${custom.juju}) $fill $time
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
      };
      hostname = {
        format = "[@$hostname]($style) ";
        ssh_only = false;
        style = "bold green";
      };
      shlvl = {
        format = "[$shlvl]($style) ";
        style = "bold cyan";
        threshold = 2;
        repeat = true;
        disabled = false;
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
      };

      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
      };
      nix_shell = {
        format = "[($name \\(develop\\) <- )$symbol]($style) ";
        impure_msg = "";
        symbol = " ";
        style = "bold red";
      };

      character = {
        error_symbol = "[~~>](bold red)";
        success_symbol = "[->>](bold green)";
        vimcmd_symbol = "[<<-](bold yellow)";
        vimcmd_visual_symbol = "[<<-](bold cyan)";
        vimcmd_replace_symbol = "[<<-](bold purple)";
        vimcmd_replace_one_symbol = "[<<-](bold purple)";
      };

      time = {
        format = "\\\[[$time]($style)\\\]";
        disabled = false;
      };

      # Cloud
      gcloud = {
        format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
      };
      aws = {
        format = "on [$symbol$profile(\\($region\\))]($style)";
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
    };
  };
}
