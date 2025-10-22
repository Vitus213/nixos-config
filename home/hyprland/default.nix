{ hostname, inputs, config, pkgs, ... }:
let
  hostSpecificHyprlandConfig = if hostname == "Vitus5600" then
    import ./../../home/hyprland/5600.nix
  else if hostname == "Vitus8500" then
    import ./../../home/hyprland/8500.nix
  else
    { };
in {
  imports = [
    ./waybar.nix
    ./dunst.nix
    ./hyprland-environment.nix
    hostSpecificHyprlandConfig
  ];

  home.packages = with pkgs; [ waybar swww ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = ''
        # 通用配置这两行是为了修复 Wayland 应用程序启动缓慢的问题，确保 systemd 正确导入和更新环境变量。
      # Fix slow startup
      exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      # Autostart
      exec-once = hyprctl setcursor Bibata-Modern-Classic 24#光标主题
      exec-once = dunst
      exec-once = clash-verge
      exec = pkill waybar & sleep 0.5 && waybar
      exec-once = swww-daemon
      exec-once = swww img ./../wallpaper/1.jpg
      exec-once =  fcitx5 --replace -d
      # Input configgr
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

                 touchpad {
                     natural_scroll = false
                 }
                 accel_profile =flat
                 sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
             }

      general {
          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
          layout = dwindle
      }

      decoration {
          rounding = 10
          blur = true
          blur_size = 3
          blur_passes = 1
          blur_new_optimizations = true

          drop_shadow = true 
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = yes
          bezier = ease,0.4,0.02,0.21,1
          animation = windows, 1, 3.5, ease, slide
          animation = windowsOut, 1, 3.5, ease, slide
          animation = border, 1, 6, default
          animation = fade, 1, 3, ease
          animation = workspaces, 1, 3.5, ease
      }

      dwindle {
          pseudotile = yes
          preserve_split = yes
      }

      master {
          new_is_master = yes
      }

      gestures {
          workspace_swipe = false
      }

      # 窗口规则
      windowrule=float,^(kitty)$
      windowrule=center,^(kitty)$
      windowrule=float,^(pavucontrol)$
      windowrule=float,^(blueman-manager)$
      windowrule=size 600 500,^(kitty)$
      windowrule=size 934 525,^(mpv)$
      windowrule=float,^(mpv)$
      windowrule=center,^(mpv)$

      $mainMod = SUPER
      #启动应用
      bind = $mainMod, G, fullscreen,
      bind = $mainMod, RETURN, exec, kitty
      bind = $mainMod, F, exec, firefox
      bind = $mainMod, V, exec, code
      bind = $mainMod, Delete, exec, wlogout
      bind = $mainMod, L,exec,hyprlock
      bind = $mainMod, space, togglefloating, #float window
      bind = $mainMod, N, nmtui,
      bind = ALT, SPACE, exec, rofi -show drun
      #截屏
      bind = SHIFT,Print,exec,grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png  
      bind = , Print, exec, grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy
      bind = $mainMod, Print, exec, grim -g "$(slurp)" - | swappy -f ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png -o | wl-copy
      bind = $CTRL ,Q,killactive
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle切换布局
      # 音量控制
      bind =,XF86AudioMute,exec,pamixer -t
      bind =,XF86AudioLowerVolume,exec,pamixer -d 10
      bind =,XF86AudioRaiseVolume,exec,pamixer -i 10
      #焦点改变
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      #工作区设置
      # Switch workspaces with mainMod + [0-9]
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

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
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

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e-1
      bind = $mainMod, mouse_up, workspace, e+1

      # 鼠标
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

    '';
  };
}
