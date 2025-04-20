{ pkgs, ... }: {
  home.packages = with pkgs; [
    dotnet-sdk_9
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_9}";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.fontconfig.lib}/lib";
  };
}
