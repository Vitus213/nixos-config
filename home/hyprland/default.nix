{ inputs, config, pkgs, ... }: {
  imports = [ ./waybar.nix ];
  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    # Use the same hyprland package coming from the flake inputs to avoid
    # version/protocol mismatches between system and user packages.
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;
    plugins = [ inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars ];
    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER"; # 定义你的 Super 键 (Windows 键)
      "$fuck" = "alt";
      # 启动应用程序的快捷键示例
      bind = [
        "$mod, Q, exec, alacritty" # Super + Q 启动 kitty 终端
        "$mod, E, exec, thunar" # Super + E 启动 Thunar 文件管理器
        "$mod, R, exec, rofi -show drun" # Super + R 启动 Rofi
        "$mod, M, exec, wlogout" # Super + M 启动 wlogout
        "$mod, delete, exec, hyprlock" # Super + Delete 锁屏
        #切换浮动窗口
        "$mod, F, togglefloating," # 切换当前窗口的浮动状态
        #工作区设置
        # 浮动窗口鼠标操作 (拖动和调整大小)
        "$mod, mouse:272, movewindow" # Super + 鼠标左键拖动窗口
        "$mod, mouse:273, resizewindow" # Super + 鼠标右键调整窗口大小

        "$mod, 1, workspace, 1" # 切换到工作区 1
        "$mod, 2, workspace, 2" # 切换到工作区 2
        # ... (1 到 10 或更多)

        "$mod SHIFT, 1, movetoworkspace, 1" # 将当前窗口移动到工作区 1
        "$mod SHIFT, 2, movetoworkspace, 2" # 将当前窗口移动到工作区 2
        # ... (1 到 10 或更多)

        "$mod, mouse_down, workspace, e+1" # 鼠标滚轮向下切换到下一个工作区
        "$mod, mouse_up, workspace, e-1" # 鼠标滚轮向上切换到上一个工作区
      ];

      # 默认自启动应用程序
      exec-once = [
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # Wayland 环境必备
        "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # Wayland 环境必备
        "swww init &" # Swww 壁纸服务
        "swww img ~/.config/hypr/wallpapers/default.jpg" # 设置壁纸 (确保路径存在)
        "waybar &" # 启动 Waybar
        "nm-applet --indicator &" # 启动网络管理器图标
        "kdeconnect-indicator &" # 启动 KDE Connect 指示器
        "hyprnotificationcenter &" # 启动通知中心 (如果你的通知中心是 hyprnotificationcenter)
        # "polkit-kde-authentication-agent-1 &" # 确保 polkit 代理运行
      ];

      # 其他 Hyprland 设置 (布局, 动画等)
      # 例如：
      layout.master.new_is_master = true;
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };
    };
    extraConfig = ''
      plugin:hyprbars:bar_height = 20
    '';
  };
  # home.file."~/.config/hypr/hyprland.conf".source = ./hyprland.conf;
}
