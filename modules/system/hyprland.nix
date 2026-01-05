{
  pkgs,
  inputs,
  ...
}:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{

  programs = {
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

}
