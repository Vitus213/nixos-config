{ pkgs, ... }:
{
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };

    # fcitx5 Classic UI 配置
    # 尝试修复多显示器下候选框位置问题
    "fcitx5/conf/classicui.conf" = {
      text = ''
        Theme=catppuccin-mocha-pink
        # 禁用 Per Screen DPI，避免多显示器位置计算错误
        PerScreenDPI=False
        # 强制 Wayland DPI
        ForceWaylandDPI=96
        # 启用分数缩放支持
        EnableFractionalScale=True
      '';
      force = true;
    };

    # GTK 输入法配置
    # 这些配置只对 X11/XWayland 应用生效
    # Wayland 原生应用会使用 text-input-v3 协议，不受这些配置影响
    # 参考: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
    "gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-im-module=fcitx
      '';
    };
    "gtk-4.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-im-module=fcitx
      '';
    };
  };

  # GTK2 配置（用于旧的 X11 应用）
  home.file.".gtkrc-2.0".text = ''
    gtk-im-module="fcitx"
  '';

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      # for flypy chinese input method
      fcitx5-rime
      # needed enable rime using configtool after installed
      qt6Packages.fcitx5-configtool
      # fcitx5-chinese-addons # we use rime instead
      # fcitx5-mozc    # japanese input method
      fcitx5-gtk # gtk im module
    ];
  };
}
