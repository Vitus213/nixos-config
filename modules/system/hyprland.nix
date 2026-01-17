{
  pkgs,
  inputs,
  ...
}:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  imports = [
    inputs.tail.nixosModules.default
  ];

  services.tail = {
    enable = true;
    user = "Vitus213"; # 替换为您的用户名
    afkTimeout = 300; # AFK 超时时间（秒）
    logLevel = "info"; # 日志级别: error, warn, info, debug, trace
    autoStart = true; # 自动启动
  };

  programs = {
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    nm-applet.indicator = true;
    thunar.enable = true;
    thunar.plugins = with pkgs; [
      xfce4-exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
    zsh.enable = true;
  };
  # ========== Hyprland 窗口管理器 ==========
  programs.hyprland = {
    enable = true;
    # withUWSM = false;
    # package = hyprlandPackage;
    # portalPackage =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ========== xdg-desktop-portal (应用认证、文件选择、屏幕共享) ==========
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      Hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

}
