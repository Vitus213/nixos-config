# This file is specific to host1
{ config, pkgs, ... }: {
  wayland.windowManager.hyprland.extraConfig = ''
    # Monitor for Host 1
    monitor=DP-1,2560x1440@60,0x0,1,transform,1
    monitor=DP-2,2560x1440@200,2160x0,1

    # 为显示器分配工作区 for Host 1
    workspace = 1, monitor:DP-1
    workspace = 2, monitor:DP-1
    workspace = 3, monitor:DP-1
    workspace = 4, monitor:DP-1
    workspace = 5, monitor:DP-1
    workspace = 6, monitor:DP-1
    workspace = 7, monitor:DP-1
    workspace = 8, monitor:DP-1
    workspace = 9, monitor:DP-1
    workspace = 0, monitor:DP-1
    workspace = 1, monitor:DP-2
    workspace = 2, monitor:DP-2
    workspace = 3, monitor:DP-2
    workspace = 4, monitor:DP-2
    workspace = 5, monitor:DP-2
    workspace = 6, monitor:DP-2
    workspace = 7, monitor:DP-2
    workspace = 8, monitor:DP-2
    workspace = 9, monitor:DP-2
    workspace = 0, monitor:DP-2
  '';
}