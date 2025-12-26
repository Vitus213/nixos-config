{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.desktop.kde;
in
{
  options.modules.desktop.kde = {
    enable = lib.mkEnableOption "KDE Plasma desktop environment";

    sddm = {
      enable = lib.mkEnableOption "SDDM display manager" // {
        default = true;
      };
      wayland.enable = lib.mkEnableOption "Wayland support for SDDM" // {
        default = true;
      };
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional KDE packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable KDE Plasma6
    services.desktopManager.plasma6.enable = true;

    # Configure SDDM display manager
    services.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      wayland.enable = cfg.sddm.wayland.enable;
      settings = {
        Autologin = {
          # 可以通过模块选项配置自动登录
          # User = "username";
          # Session = "plasma";
        };
      };
    };

    # Essential KDE packages
    environment.systemPackages =
      with pkgs;
      [
        # Core KDE applications
        kdePackages.discover # Software center (Flatpak/fwupd support)
        kdePackages.kcalc # Calculator
        kdePackages.kcharselect # Character selector
        kdePackages.kclock # Clock app
        kdePackages.kcolorchooser # Color picker
        kdePackages.kolourpaint # Paint program
        kdePackages.ksystemlog # System log viewer
        kdePackages.sddm-kcm # SDDM configuration module
        kdePackages.isoimagewriter # ISO image writer
        kdePackages.partitionmanager # Partition manager

        # File comparison and utilities
        kdiff3 # File/directory comparison tool

        # System tools
        hardinfo2 # System information and benchmarks

        # Media
        vlc # Media player

        # Wayland utilities (for KDE on Wayland)
        wayland-utils
        wl-clipboard
      ]
      ++ cfg.extraPackages;

    # Enable essential services for KDE
    programs.dconf.enable = true;

    # For better Qt application theming
    qt = {
      enable = true;
      platformTheme = "kde";
    };

    # XDG portal for better desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
      ];
    };
  };
}
