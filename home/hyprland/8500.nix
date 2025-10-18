# This file is specific to host2
{ config, pkgs, ... }: {
  wayland.windowManager.hyprland.extraConfig = ''
    monitor=DP-1,1920x1080@60,1920x0,1
    monitor=eDP-1,1920x1080@60,0x0,1
    workspace = 1, monitor:eDP-1
    workspace = 2, monitor:eDP-1
    workspace = 3, monitor:eDP-1
    workspace = 4, monitor:eDP-1
    workspace = 5, monitor:eDP-1
    workspace = 6, monitor:DP-1
    workspace = 7, monitor:DP-1
    workspace = 8, monitor:DP-1
    workspace = 9, monitor:DP-1
    workspace = 0, monitor:DP-1
  '';
}