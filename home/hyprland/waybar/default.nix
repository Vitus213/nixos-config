{ config, lib, pkgs, ... }:

{
  # programs.waybar模块用于在NixOS中配置Waybar
  programs.waybar = {
    # 启用Waybar
    enable = true;

    # systemd服务管理配置
    systemd = {
      # 不启用systemd服务来管理Waybar。
      # 如果设置为true, Waybar会作为一个系统服务运行。
      # 对于大多数桌面环境，由窗口管理器或启动脚本启动Waybar更常见。
      enable = false;
      # 如果启用systemd，指定服务所属的目标。
      target = "graphical-session.target";
    };

    # 这是Waybar的CSS样式配置，用于定义其外观。
    style = ''
            /* ===== 全局样式 ===== */
            /* "*" 是一个通用选择器，适用于所有模块和元素 */
            * {
              /* 设置默认字体，这里使用了带Nerd Font图标的JetBrains Mono字体 */
              font-family: "JetBrainsMono Nerd Font";
              /* 设置默认字体大小 */
              font-size: 12pt;
              /* 设置默认字体粗细为粗体 */
              font-weight: bold;
              /* 为所有元素的边角设置8像素的圆角 */
              border-radius: 8px;
              /* 指定背景颜色变化时应用过渡效果 */
              transition-property: background-color;
              /* 过渡效果的持续时间为0.5秒 */
              transition-duration: 0.5s;
            }

            /* ===== 动画定义 ===== */
            /* 定义一个名为 "blink_red" 的关键帧动画 */
            @keyframes blink_red {
              /* 动画结束状态 */
              to {
                /* 将背景颜色变为指定的红色 */
                background-color: rgb(242, 143, 173);
                /* 将文字颜色变为指定的深色 */
                color: rgb(26, 24, 38);
              }
            }
            /* 为具有 "warning", "critical", "urgent" 类的模块应用动画 */
            .warning, .critical, .urgent {
              /* 应用上面定义的 "blink_red" 动画 */
              animation-name: blink_red;
              /* 动画单次循环持续1秒 */
              animation-duration: 1s;
              /* 动画速度曲线为线性 */
              animation-timing-function: linear;
              /* 无限次重复动画 */
              animation-iteration-count: infinite;
              /* 动画在每个循环结束时反向播放 */
              animation-direction: alternate;
            }

            /* ===== Waybar主窗口和容器样式 ===== */
            /* 选中Waybar的主窗口 (window#waybar) */
            window#waybar {
              /* 设置主窗口背景为透明，这样可以看到桌面壁纸 */
              background-color: transparent;
            }
            /* 选中主窗口内的直接子元素 "box" 容器 */
            window > box {
              /* 设置容器的左、右、上外边距 */
              margin-left: 5px;
              margin-right: 5px;
              margin-top: 5px;
              /* 设置容器的背景颜色 */
              background-color: transparent;
              /* 设置容器的内边距 */
              padding: 3px;
              padding-left:8px;
              /* 设置边框，这里虽然定义了宽度和颜色，但样式为 "none"，即无边框 */
              border: 2px none #33ccff;
            }

            /* ===== 各模块的独立样式 ===== */
            /* Hyprland/Sway 工作区模块 */
      #workspaces {
              padding-left: 0px;
              padding-right: 4px;
            }
      /* 工作区模块中的每个按钮 */
      #workspaces button {
              padding-top: 5px;
              padding-bottom: 5px;
              padding-left: 6px;
              padding-right: 6px;
            }
      /* 当前活动的工作区按钮 */
      #workspaces button.active {
              background-color: rgb(181, 232, 224);
              color: rgb(26, 24, 38);
            }
      /* 处于 "urgent" (紧急) 状态的工作区按钮 */
      #workspaces button.urgent {
              color: rgb(26, 24, 38);
            }
      /* 鼠标悬停在工作区按钮上时的样式 */
      #workspaces button:hover {
              background-color: rgb(248, 189, 150);
              color: rgb(26, 24, 38);
            }

            /* 鼠标悬停时出现的工具提示框 */
            tooltip {
              background: rgb(48, 45, 65);
            }
            /* 工具提示框内的文本标签 */
            tooltip label {
              color: rgb(217, 224, 238);
            }
            
            /* 自定义启动器模块 */
      #custom-launcher {
              font-size: 20px;
              padding-left: 8px;
              padding-right: 6px;
              color: #7ebae4;
            }

            /* 为多个模块设置统一的左右内边距 */
      #mode, #clock, #memory,#cpu,#mpd, #custom-wall,  #backlight, #pulseaudio, #network, #battery, #custom-powermenu, #custom-cava-internal {
              padding-left: 10px;
              padding-right: 10px;
            }
            
            /* 内存使用率模块 */
      #memory {
              color: rgb(181, 232, 224);
            }
            /* CPU使用率模块 */
      #cpu {
              color: rgb(245, 194, 231);
            }
            /* 时钟模块 */
      #clock {
              color: rgb(217, 224, 238);
            }
            /* 自定义壁纸模块 */
      #custom-wall {
              color: #33ccff;
         }
            /* 屏幕亮度模块 */
      #backlight {
              color: rgb(248, 189, 150);
            }
            /* 音频 (Pulseaudio) 模块 */
      #pulseaudio {
              color: rgb(245, 224, 220);
            }
            /* 网络模块 */
      #network {
              color: #ABE9B3;
            }
            /* 网络模块在断开连接时的样式 */
      #network.disconnected {
              color: rgb(255, 255, 255);
            }
            /* 自定义电源菜单模块 */
      #custom-powermenu {
              color: rgb(242, 143, 173);
              padding-right: 8px;
            }
            /* 系统托盘模块 */
      #tray {
              padding-right: 8px;
              padding-left: 10px;
            }
            /* MPD音乐播放器模块在暂停时的样式 */
      #mpd.paused {
              color: #414868;
              font-style: italic;
            }
            /* MPD模块在停止时的样式 */
      #mpd.stopped {
              background: transparent;
            }
            /* MPD模块的默认样式 */
      #mpd {
              color: #c0caf5;
            }
            /* 自定义Cava音频可视化模块 */
      #custom-cava-internal{
              /* 为这个模块特别指定字体 */
              font-family: "Hack Nerd Font" ;
              color: #33ccff;
            }
    '';

    # 这是Waybar的功能配置，用于定义模块的行为和位置。
    # 使用一个列表可以支持多个bar的配置，这里只有一个。
    settings = [{
      # Waybar所在的图层，"top"表示在大多数窗口之上
      "layer" = "top";
      # Waybar在屏幕上的位置，"top"表示顶部
      "position" = "top";

      # Waybar左侧的模块列表
      modules-left = [
        "custom/launcher"
        "mpd"
        "custom/cava-internal"
        "hyprland/workspaces"
      ];
      # Waybar中间的模块列表
      modules-center = [ "wlr/taskbar" ];
      # Waybar右侧的模块列表
      modules-right = [
        "pulseaudio"
        "backlight"
        "memory"
        "cpu"
        "network"
        "custom/powermenu"
        "tray"
        "clock"
      ];

      # --- 各模块详细配置 ---

      "custom/launcher" = {
        "format" = " "; # 显示的图标 (NixOS Logo)
        "on-click" = "thunar"; # 左键单击：打开Thunar文件管理器
        "on-click-middle" = "exec default_wall"; # 中键单击：执行脚本设置默认壁纸
        "on-click-right" = "exec wallpaper_random"; # 右键单击：执行脚本随机切换壁纸
        "tooltip" = false; # 禁用工具提示
      };

      "custom/cava-internal" = {
        # 启动1秒后执行cava-internal命令，用于音频可视化
        "exec" = "sleep 1s && cava-internal";
        "tooltip" = false;
      };

      "pulseaudio" = {
        "scroll-step" = 1; # 每次滚轮滚动调整1%的音量
        "format" = "{icon} {volume}%"; # 显示格式：图标 + 音量百分比
        "format-muted" = "󰖁 Muted"; # 静音时显示格式
        "format-icons" = { "default" = [ "" "" "" ]; }; # 根据音量大小显示不同的图标
        "on-click" = "pamixer -t"; # 左键单击：切换静音
        "on-click-middle" = "pavucontrol"; # 中键单击：打开pavucontrol音量控制面板
        "tooltip" = false;
      };

      "clock" = {
        "interval" = 1; # 每秒更新一次
        "format" = "{:%I:%M %p  %A %b %d}"; # 显示格式：小时:分钟 上下午 星期 月份 日期
        "tooltip" = true; # 启用工具提示
        # 工具提示的格式，可以显示更详细的信息和日历
        "tooltip-format" = ''
          {=%A; %d %B %Y}
          <tt>{calendar}</tt>'';
      };

      "memory" = {
        "interval" = 1; # 每秒更新一次
        "format" = "󰻠 {percentage}%"; # 显示格式：图标 + 内存使用百分比
        "states" = {
          "warning" = 85;
        }; # 当使用率超过85%时，添加 "warning" 类 (会触发上面的CSS动画)
      };

      "cpu" = {
        "interval" = 1; # 每秒更新一次
        "format" = "󰍛 {usage}%"; # 显示格式：图标 + CPU使用率
      };

      "mpd" = {
        "max-length" = 25; # 歌曲标题最大显示长度
        "format" = "<span foreground='#bb9af7'></span> {title}"; # 播放时格式
        "format-paused" = " {title}"; # 暂停时格式
        "format-stopped" = "<span foreground='#bb9af7'></span>"; # 停止时格式
        "format-disconnected" = ""; # 未连接时为空
        "on-click" = "mpc --quiet toggle"; # 左键单击：播放/暂停
        "on-click-right" = "mpc update; mpc ls | mpc add"; # 右键单击：更新并添加所有歌曲到播放列表
        "on-click-middle" =
          "kitty --class='ncmpcpp' ncmpcpp "; # 中键单击：在kitty中打开ncmpcpp
        "on-scroll-up" = "mpc --quiet prev"; # 向上滚动：上一曲
        "on-scroll-down" = "mpc --quiet next"; # 向下滚动：下一曲
        "smooth-scrolling-threshold" = 5; # 平滑滚动阈值
        "tooltip-format" =
          "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})"; # 工具提示格式
      };

      "network" = {
        "format-disconnected" = "󰯡 "; # 断开连接时图标
        "format-ethernet" = "󰒢 "; # 有线网络图标
        "format-linked" = "󰖪 {essid} (No IP)"; # 已连接但无IP时
        "format-wifi" = "󰖩 {essid}"; # Wi-Fi连接时：图标 + Wi-Fi名称
        "interval" = 1; # 每秒更新一次
        "tooltip" = false; # 禁用工具提示
        "on-click" = "kitty -e nmtui"; # 左键单击：在kitty中打开nmtui网络管理器
      };

      "custom/powermenu" = {
        "format" = ""; # 显示电源图标
        "on-click" = "wlogout"; # 左键单击：打开wlogout电源菜单
        "tooltip" = false;
      };

      "tray" = {
        "icon-size" = 20; # 系统托盘图标大小
        "spacing" = 10; # 图标之间的间距
      };

      "hyprland/workspaces" = {
        "format" = "{name} = {icon}"; # 工作区显示格式
        "format-icons" = { # 为不同工作区和状态定义图标
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "";
          "7" = "";
          "8" = "";
          "9" = "";
          "10" = "";
          "active" = ""; # 活动工作区的图标
          "default" = ""; # 默认图标
        };
      };

      "wlr/taskbar" = {
        "format" = "{icon}"; # 任务栏只显示应用程序图标
        "tooltip" = true;
        "tooltip-format" = "{title}"; # 工具提示显示窗口标题
        "on-click" = "activate"; # 左键单击：激活窗口
        "on-click-middle" = "close"; # 中键单击：关闭窗口
        "active-first" = true; # 优先显示当前活动窗口的任务
      };
    }];
  };
}
