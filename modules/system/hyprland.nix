{
  pkgs,
  inputs,
  ...
}:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  # ========== Hyprland 窗口管理器 ==========
  services.displayManager.sessionPackages = [ hyprlandPackage ];

  programs = {
    hyprland = {
      enable = true;
      withUWSM = false;
      package = hyprlandPackage;
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

  nixpkgs.config.allowUnfree = true;
}
