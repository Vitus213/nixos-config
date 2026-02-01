{
  pkgs,
  config,
  hostname,
  inputs,
  ...
}:
let
  # 使用 flake inputs 中的 hyprland，保持与系统级配置一致
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  xdg.configFile =
    let
      repoConf = "${config.home.homeDirectory}/nixos-config/home/linux/gui/hyprland/conf";
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      "hypr/configs".source = mkSymlink repoConf;
    };

  # xdg.configFile ={
  #   "hypr/configs".source = config.lib.file.mkOutOfStoreSymlink repoConf;
  # };
  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
  };
  wayland.windowManager.hyprland.plugins = [
    # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprwinwrap
    #pkgs.hyprlandPlugins.hyprexpo
    pkgs.hyprlandPlugins.hyprwinwrap
    pkgs.hyprlandPlugins.hyprscrolling
  ];
  wayland.windowManager.hyprland.settings = {
    source =
      let
        configPath = "${config.home.homeDirectory}/.config/hypr/configs";
        hostSpecificHyprlandConfig =
          if hostname == "Vitus5600" then
            # 如果主机名是 "Vitus5600"，就导入 5600.nix 文件。
            "${configPath}/5600.conf"
          else if hostname == "Vitus8500" then
            # 如果主机名是 "Vitus8500"，就导入 8500.nix 文件。
            "${configPath}/8500.conf"
          else
            # 如果主机名不匹配任何已知的主机，则返回一个空配置集，不应用任何特定配置。
            { };
      in
      [
        hostSpecificHyprlandConfig
        "${configPath}/fcitx5.conf"
        "${configPath}/windowrules.conf"
      ];
    env = [
      "QT_IM_MODULE,fcitx"
      # "GTK_IM_MODULE,fcitx"
      "XMODIFIERS,@im=fcitx"
      "SDL_IM_MODULE,fcitx"
      "GLFW_IM_MODULE,ibus"
    ];
    animations = {
      bezier = "wpBezier, 0.1, 1, 0.3, 1";

      animation = [
        "windows, 1, 6, wpBezier, slide"
        "windowsIn, 1, 6, wpBezier, popin"
        "workspaces, 1, 6, wpBezier, slidevert"
      ];
    };
    input = {
      accel_profile = "flat";
      sensitivity = 0;
      follow_mouse = 1;
    };
    general = {
      allow_tearing = true;
      layout = "scrolling";
      gaps_in = 4;
      gaps_out = 5;
      #       resize_on_border = true;
      # # 扩展抓取范围（单位：像素）
      # # 设为 15-20 通常比较舒服
      # extend_border_grab_area = 10;

      # # 只有鼠标靠近边框时才会显示调整图标
      # hover_icon_on_border = true;
    };
    debug = {
      disable_logs = false;
    };
    exec-once = [
      "dbus-update-activation-environment --systemd --all"
      "systemctl --user import-environment --all"
      "systemctl --user restart xdg-desktop-portal-gtk.service xdg-desktop-portal-hyprland.service xdg-desktop-portal.service"
      "${pkgs.waybar}/bin/waybar"
      "systemctl --user start hypridle.service mako.service hyprpolkitagent"
      "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular"
      "${pkgs.swaybg}/bin/swaybg -c '#282828'"
      "${pkgs.glava}/bin/glava -e bg.glsl"
      "${pkgs.clash-verge-rev}/bin/clash-verge &"

    ];
    decoration = {
      rounding = 10; # 稍微大一点的圆角更美观
      active_opacity = 1.0;
      inactive_opacity = 1.0; # 让后台窗口更透明一点，效果更明显

      blur = {
        enabled = true;
        size = 3;
        passes = 2; # 增加到 2 次，模糊效果会更细腻（像磨砂玻璃）
        vibrancy = 0.1696;
        new_optimizations = true; # 记得加上这个性能优化
      };

      shadow = {
        enabled = true;
        range = 4;
        color = "rgba(1a1a1aee)"; # 深色阴影
      };
    };
    # layerrule = [
    #   "blur, waybar"
    #   "ignorezero, waybar"
    #   "ignorealpha 0.5, waybar"
    #   "noanim, anyrun"
    # ];
    plugin = {
      hyprscrolling = {
        focus_fit_method = 1;
        follow_focus = true;
        fullscreen_on_one_column = true;
      };
      hyprwinwrap = {
        # class = "GLava";
        title = "GLava-Background";
        # pos_x = 25;
        # pos_y = 30;
        # # you can add the size of the window in a percentage
        # size_x = 40;
        # size_y = 70;
      };
    };
    misc = {
      disable_hyprland_logo = true;
    };
  };

  services.polkit-gnome.enable = true; # polkit
}
