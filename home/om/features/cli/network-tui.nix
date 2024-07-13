# TUI network tools
# https://phoenixnap.com/kb/linux-network-bandwidth-monitor-traffic
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    iftop
    bmon
    nethogs
    nmap
  ];
}
