{ config, pkgs, ... }:
let
  terminal = "${pkgs.kitty}/bin/kitty";
  mod = "SUPER";
in
{
  home.packages = with pkgs; [
    playerctl # 媒体控制
    grim # 截图
    slurp # 区域选择
    swappy # 截图编辑
  ];

  wayland.windowManager.hyprland.settings = {
    # --- 滚轮设置 ---
    binds = {
      scroll_event_delay = 0;
    };

    # --- 鼠标绑定 ---
    bindm = [
      "${mod}, mouse:272, movewindow" # Super + 左键拖动窗口
      "${mod}, mouse:273, resizewindow" # Super + 右键调整大小
    ];

    # --- 重复触发绑定 (音量键长按) ---
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    # --- 触发一次绑定 (静音、媒体控制) ---
    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"
    ];

    # --- 普通快捷键 ---
    bind = [
      # ========== 应用程序启动 ==========
      "${mod}, F, fullscreenstate, 1 3"
      "${mod}, U, fullscreen"
      "${mod}, SPACE, exec, ${terminal}"
      "${mod}, E, exec, ${pkgs.microsoft-edge}/bin/microsoft-edge"
      "${mod}, V, exec, ${pkgs.vscode}/bin/code"
      "${mod}, D, exec, ${pkgs.firefox}/bin/firefox"
      "${mod}, Z, exec, zeditor"
      "${mod}, N, exec, ${pkgs.networkmanager}/bin/nmtui"
      "${mod}, Delete, exec, ${pkgs.wlogout}/bin/wlogout"
      "ALT, SPACE, exec, ${pkgs.anyrun}/bin/anyrun"

      # ========== 截图 ==========
      "SHIFT, Print, exec, grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
      ", Print, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy"
      "${mod}, Print, exec, grim -g \"$(slurp)\" - | ${pkgs.swappy}/bin/swappy -f -"

      # ========== 窗口管理 ==========
      "${mod}, Q, killactive" # 关闭窗口
      "${mod}, K, togglefloating" # 浮动/平铺切换
      "${mod}, J, togglesplit" # 水平/垂直分割切换
      "${mod}, Tab, hyprexpo:expo, toggle" # 工作区概览
      "${mod}, Return, layoutmsg, swapwithmaster master"

      # ========== Scrolling 布局操作 ==========
      "${mod}, mouse_up, layoutmsg, move +col" # 窗口移到上一列
      "${mod}, mouse_down, layoutmsg, move -col" # 窗口移到下一列
      "${mod}, Equal, layoutmsg, colresize +conf" # 当前列变宽
      "${mod}, Minus, layoutmsg, colresize -conf" # 当前列变窄

      # ========== SUPER + ALT 窗口操作 ==========
      "${mod}_ALT, bracketleft, layoutmsg, movewindowto l" # 移动窗口到左列
      "${mod}_ALT, bracketright, layoutmsg, movewindowto r" # 移动窗口到右列
      "${mod}_ALT, Left, layoutmsg, swapcol l" # 交换左右列
      "${mod}_ALT, Right, layoutmsg, swapcol r" # 交换左右列
      "${mod}_ALT, Up, movewindow, u" # 移动窗口向上
      "${mod}_ALT, Down, movewindow, d" # 移动窗口向下

      # ========== 焦点切换 ==========
      "${mod}, left, movefocus, l"
      "${mod}, right, movefocus, r"
      "${mod}, up, movefocus, u"
      "${mod}, down, movefocus, d"

      # ========== 窗口循环切换 ==========
      "ALT, Tab, cyclenext, next"
      "ALT_SHIFT, Tab, cyclenext, prev"

      # ========== 鼠标滚轮切换工作区 ==========
      "CTRL_${mod}, up, workspace, r-1"
      "CTRL_${mod}, down, workspace, r+1"
      "CTRL_${mod}, mouse_down, workspace, r-1"
      "CTRL_${mod}, mouse_up, workspace, r+1"

      # ========== Group 窗口组 ==========
      "${mod}, T, togglegroup"
      "${mod}, grave, changegroupactive, f"
    ]
    ++ (
      # ========== 工作区 1-9 ==========
      builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
          in
          [
            "${mod}, ${ws}, workspace, ${ws}"
            "${mod} SHIFT, ${ws}, movetoworkspace, ${ws}"
          ]
        ) 9
      )
    );
  };
}
