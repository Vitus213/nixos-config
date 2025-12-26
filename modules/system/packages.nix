{
  pkgs,
  inputs,
  host,
  ...
}:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  # 将 Hyprland 添加到 displayManager 的 sessionPackages，
  # 这样 ly 才能找到 wayland-sessions 中的 .desktop 文件
  services.displayManager.sessionPackages = [ hyprlandPackage ];

  programs = {
    hyprland = {
      enable = true;
      withUWSM = false;  # uwsm 与当前 Hyprland 版本不兼容 (--watchdog-fd 未支持)
      package = hyprlandPackage;
      # make sure to also set the portal package, so that they are in sync
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    nm-applet.indicator = true;
    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
    zsh.enable = true;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.tailscale.enable = true;
  nixpkgs.config.allowUnfree = true;
}
