{ pkgs, ... }:

{

  xdg.portal = {
    enable = true; # 启用 XDG 桌面门户服务
    wlr.enable = true; # 支持 Wayland 混成器（如 Sway/Hyprland）
    extraPortals = [ # 指定额外的门户实现
      pkgs.xdg-desktop-portal-gtk # GTK 版本（提供传统桌面集成）
      pkgs.xdg-desktop-portal-wlr # Wayland 专用版本
    ];
    configPackages = [ # 指定提供配置文件的包
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };
}
