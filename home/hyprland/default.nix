# 这是一个 Nix 函数，接收一组预定义的参数，如 hostname, pkgs 等。
# 这是 NixOS 和 home-manager 配置的标准写法。
{ hostname, inputs, config, pkgs, ... }:

let
  # --- 主机特定配置 ---
  # 根据当前的主机名 (hostname) 动态导入不同的配置文件。
  # 这种模式使得在多台机器上共享大部分配置，同时保留个别差异成为可能。
  hostSpecificHyprlandConfig = if hostname == "Vitus5600" then
  # 如果主机名是 "Vitus5600"，就导入 5600.nix 文件。
    import ./../../home/hyprland/5600.nix
  else if hostname == "Vitus8500" then
  # 如果主机名是 "Vitus8500"，就导入 8500.nix 文件。
    import ./../../home/hyprland/8500.nix
  else
  # 如果主机名不匹配任何已知的主机，则返回一个空配置集，不应用任何特定配置。
    { };

  # 定义壁纸文件夹的路径，方便在下面的配置中引用。
  # `${./../wallpaper}` 表示相对于当前文件位置的路径。
  wallpaperpath = "${./../wallpaper}";

in {
  # --- 模块导入 ---
  # 导入其他 Nix 配置文件。这是组织和模块化配置的主要方式。
  imports = [
    ./waybar # 导入 Waybar (状态栏) 的配置。
    ./dunst # 导入 Dunst (通知守护进程) 的配置。
    ./hyprland-environment.nix # 导入 Hyprland 相关的环境变量设置。
    ./hyprlock # 导入 hyprlock (锁屏程序) 的配置。
    ./hypridle
    hostSpecificHyprlandConfig # 导入上面 let 块中定义的、特定于主机的配置。
  ];

  # --- 安装软件包 ---
  # home.packages 用于为用户安装指定的软件包。
  home.packages = with pkgs; [
    waybar # 状态栏
    swww # 高效的 Wayland 壁纸程序
  ];

  # --- Hyprland 窗口管理器配置 ---
  wayland.windowManager.hyprland = {
    # 启用 Hyprland 窗口管理器。
    enable = true;
    # 启用 systemd 服务来管理 Hyprland 会话，有助于改善启动和环境管理。
    systemd.enable = true;
    # extraConfig 允许我们写入原生的 Hyprland 配置文件内容。
    extraConfig = ''
      #=================================================================#
      # 环境与自启动 (Environment & Autostart)                          #
      #=================================================================#

      # 这两行是为了修复 Wayland 应用程序（特别是 Flatpak 应用）启动缓慢或无法启动的问题。
      # 它们确保了关键的环境变量被 systemd 和 D-Bus 正确导入和更新。
      exec = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec = dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      # 'exec-once' 命令只在 Hyprland 首次启动时执行一次。
      exec-once = systemctl --user start hyprpolkitagent # 启动 Polkit 代理，用于处理需要管理员权限的操作（如磁盘挂载）。
      exec-once = hyprctl setcursor Bibata-Modern-Classic 24 # 设置光标主题和大小。
      exec-once = dunst # 启动 dunst 通知守护进程。
      exec-once = clash-verge # 启动 Clash Verge 代理客户端。
      exec-once = aw-qt
      # 'exec' 命令每次重载配置时都会执行。
      # 这是一个重启 waybar 的技巧：先杀死所有 waybar 进程，暂停0.5秒确保完全退出，然后再启动新的 waybar 实例。
      exec = pkill waybar & sleep 0.5 && waybar
      exec-once = swww-daemon # 启动 swww 壁纸守护进程。
      exec-once = swww img ${wallpaperpath}/2.jpg --transition-type fade --transition-duration 3 # 设置壁纸，并指定渐变过渡效果。
      exec-once = fcitx5 --replace -d # 启动 fcitx5 输入法框架。
      exec-once = hypridle # 启动 hypridle 屏幕锁定和节能管理服务。

      #=================================================================#
      # 输入设备 (Input)                                                #
      #=================================================================#
      input {
          kb_layout = us             # 键盘布局设置为美国英语。
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1           # 焦点跟随鼠标指针移动。1 表示焦点会立即切换到鼠标指针所在的窗口。

          touchpad {
              natural_scroll = false # 关闭自然滚动（即滚动方向与手指移动方向相同）。
          }
          accel_profile = flat       # 设置鼠标加速曲线为 "flat"，即禁用指针加速。
          sensitivity = 0            # 鼠标灵敏度，范围从 -1.0 到 1.0，0 表示不修改。
      }

      #=================================================================#
      # 通用设置 (General)                                              #
      #=================================================================#
      general {
          gaps_in = 5                # 窗口之间的内部间距。
          gaps_out = 10              # 窗口与屏幕边缘的外部间距。
          border_size = 2            # 窗口边框的宽度。
          # 活动窗口边框颜色，使用45度角的渐变色。
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          # 非活动窗口边框颜色。
          col.inactive_border = rgba(595959aa)
          layout = dwindle           # 默认的窗口布局引擎。dwindle 是一种类似二叉树的平铺布局。
      }

      #=================================================================#
      # 装饰效果 (Decoration)                                           #
      #=================================================================#
      decoration {
          rounding = 10              # 窗口圆角大小。
          
          # 毛玻璃/模糊效果配置
          blur = true                # 启用背景模糊。
          blur_size = 3              # 模糊内核大小。
          blur_passes = 1            # 模糊处理的遍数。
          blur_new_optimizations = true # 启用新的模糊优化。

          # 窗口阴影配置
          drop_shadow = true         # 启用窗口阴影。
          shadow_range = 4           # 阴影范围。
          shadow_render_power = 3    # 阴影渲染强度，值越高阴影越柔和。
          col.shadow = rgba(1a1a1aee) # 阴影颜色。
      }

      #=================================================================#
      # 动画效果 (Animations)                                           #
      #=================================================================#
      animations {
          enabled = yes              # 启用动画效果。
          # 定义一个名为 'ease' 的贝塞尔曲线，用于创建平滑的动画效果。
          bezier = ease,0.4,0.02,0.21,1
          # 定义各种动画。格式为：animation = <类型>, <开关>, <速度>, <曲线>, [风格]
          animation = windows, 1, 3.5, ease, slide # 窗口出现动画：滑动，速度3.5，使用'ease'曲线。
          animation = windowsOut, 1, 3.5, ease, slide # 窗口消失动画。
          animation = border, 1, 6, default      # 边框颜色变化的动画。
          animation = fade, 1, 3, ease           # 淡入淡出动画。
          animation = workspaces, 1, 3.5, ease   # 工作区切换动画。
      }

      #=================================================================#
      # 布局设置 (Layouts)                                              #
      #=================================================================#
      dwindle {
          pseudotile = yes           # 启用伪平铺模式。在新窗口打开时，主窗口会保持大小，而不是被压缩。
          preserve_split = yes       # 保持分割方向（例如，如果你是垂直分割，下一个窗口也会是垂直分割）。
      }

      master {
          new_is_master = yes        # 新打开的窗口成为主窗口（master）。
      }

      #=================================================================#
      # 手势 (Gestures)                                                 #
      #=================================================================#
      gestures {
          workspace_swipe = false    # 禁用触摸板三指或四指滑动切换工作区。
      }

      #=================================================================#
      # 窗口规则 (Window Rules)                                         #
      #=================================================================#
      # 格式: windowrule = <规则>,<窗口类名或标题>
      windowrule=float,^(kitty)$       # 让 kitty 终端窗口默认以浮动模式打开。
      windowrule=center,^(kitty)$      # 让 kitty 窗口在屏幕中央打开。
      windowrule=float,^(pavucontrol)$ # 让音量控制器浮动。
      windowrule=float,^(blueman-manager)$ # 让蓝牙管理器浮动。
      windowrule=size 600 500,^(kitty)$ # 设置 kitty 窗口的默认大小为 600x500。
      windowrule=size 934 525,^(mpv)$   # 设置 mpv 视频播放器的默认大小。
      windowrule=float,^(mpv)$         # 让 mpv 浮动。
      windowrule=center,^(mpv)$        # 让 mpv 居中。

      #=================================================================#
      # 快捷键绑定 (Keybindings)                                        #
      #=================================================================#

      # 定义主修饰键 (Modifier Key)，SUPER 通常是 "Win" 键。
      $mainMod = SUPER

      # --- 应用程序启动 ---
      bind = $mainMod, G, fullscreen,                # Super + G: 切换全屏
      bind = $mainMod, RETURN, exec, kitty           # Super + Enter: 启动 kitty 终端
      bind = $mainMod, F, exec, firefox              # Super + F: 启动 Firefox
      bind = $mainMod, V, exec, code                 # Super + V: 启动 VS Code
      bind = $mainMod, Delete, exec, wlogout         # Super + Delete: 打开 wlogout 注销菜单
      bind = $mainMod, L, exec, hyprlock             # Super + L: 锁屏
      bind = $mainMod, space, togglefloating,        # Super + Space: 切换当前窗口的浮动/平铺状态
      bind = $mainMod, N, exec, nmtui                # Super + N: 启动 nmtui (终端网络管理器)
      bind = ALT, SPACE, exec, rofi -show drun       # Alt + Space: 启动 Rofi 程序启动器

      # --- 截图 ---
      # Shift + PrintScreen: 全屏截图并保存。
      bind = SHIFT,Print,exec,grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
      # PrintScreen: 选择区域截图，保存到文件并复制到剪贴板。
      bind = , Print, exec, grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy
      # Super + PrintScreen: 选择区域截图，并在 swappy 编辑器中打开，然后复制到剪贴板。
      bind = $mainMod, Print, exec, grim -g "$(slurp)" - | swappy -f -

      # --- 窗口管理 ---
      bind = $CTRL, Q, killactive,                   # Ctrl + Q: 关闭当前活动窗口
      bind = $mainMod, P, pseudo, # dwindle          # Super + P: 切换伪平铺模式
      bind = $mainMod, J, togglesplit, # dwindle      # Super + J: 切换 dwindle 布局的分割方向 (垂直/水平)

      # --- 音量控制 (使用键盘上的多媒体键) ---
      bind = ,XF86AudioMute,exec,pamixer -t          # 静音键: 切换静音
      bind = ,XF86AudioLowerVolume,exec,pamixer -d 5 # 音量减小键: 音量降低 5%
      bind = ,XF86AudioRaiseVolume,exec,pamixer -i 5 # 音量增大键: 音量增加 5%

      # --- 焦点切换 ---
      # 使用 Super + 方向键来移动焦点
      bind = $mainMod, left, movefocus, l            # Super + 左: 焦点向左移动
      bind = $mainMod, right, movefocus, r           # Super + 右: 焦点向右移动
      bind = $mainMod, up, movefocus, u              # Super + 上: 焦点向上移动
      bind = $mainMod, down, movefocus, d            # Super + 下: 焦点向下移动

      # --- 工作区 (Workspace) ---
      # 使用 Super + 数字键切换工作区
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # 使用 Super + Shift + 数字键将活动窗口移动到指定工作区
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # 使用 Super + 鼠标滚轮来切换工作区
      bind = $mainMod, mouse_down, workspace, e-1    # 向下滚动: 切换到上一个工作区
      bind = $mainMod, mouse_up, workspace, e+1      # 向上滚动: 切换到下一个工作区

      # --- 鼠标绑定 ---
      # 按住 Super 键，然后可以...
      bindm = $mainMod, mouse:272, movewindow        # ...用鼠标左键拖动窗口。 (272是左键的事件码)
      bindm = $mainMod, mouse:273, resizewindow      # ...用鼠标右键调整窗口大小。 (273是右键的事件码)
    '';
  };
}
