{ config, lib, pkgs, ... }:

let
  # 定义图片路径为 Nix 存储路径，确保它们在构建时被复制到系统
  # 假设图片在与此Nix文件相同的目录下
  wallpaperPath = "${./2.jpg}";
  avatarPath = "${./avatar.jpg}";
in {
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = {
      # 背景图片配置
      background = [{
        path = wallpaperPath; # 使用 Nix 路径引用
        blur_passes = 3;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }];

      # 用户头像图片
      image = [{
        # monitor = ""; # 默认为所有 monitor，无需指定
        path = avatarPath; # 使用 Nix 路径引用
        border_size = 2;
        border_color = "rgba(255, 255, 255, 0)";
        size = 160;
        rounding = -1; # -1 表示圆形
        position = "0, 40"; # 注意：Nix 字符串需要引号
        halign = "center";
        valign = "center";
      }];

      # 日期显示
      label = [
        {
          # monitor = "";
          text = ''
            cmd[update:1000] echo -e "$(LC_TIME=en_US.UTF-8 date +"%A, %B %d")"'';
          color = "rgba(216, 222, 233, 0.90)";
          font_size = 25;
          font_family = "SF Pro Display Semibold"; # 确保这个字体已安装或在你的Nix配置中引入
          position = "0, 350";
          halign = "center";
          valign = "center";
        }
        # 时间显示
        {
          # monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%I:%M")</span>"'';
          color = "rgba(216, 222, 233, 0.90)";
          font_size = 120;
          font_family = "SF Pro Display Bold"; # 确保这个字体已安装或在你的Nix配置中引入
          position = "0, 230";
          halign = "center";
          valign = "center";
        }
      ];

      # 输入字段
      "input-field" = [ # 使用引号包裹，因为 '-' 是特殊字符
        {
          # monitor = "";
          size = "280, 55"; # 使用引号包裹
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(255, 255, 255, 0.1)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          font_family = "SF Pro Display Bold"; # 确保这个字体已安装或在你的Nix配置中引入
          placeholder_text =
            "<i><span foreground='##ffffff99'>🔒 Enter Pass</span></i>"; # 使用单引号在内部
          hide_input = false;
          position = "0, -210";
          halign = "center";
          valign = "center";
        }
      ];
    };
    # extraConfig = ''; # 这里不再需要 extraConfig，所有内容都移到了 settings
  };

  # 确保字体可用 (示例，你需要根据实际情况调整)
  # environment.systemPackages = with pkgs; [
  #   # 例如，如果你有 sf-pro-display 字体包
  #   # font-awesome # 如果你在其他地方使用了图标字体
  # ];
  # 或者通过 font.fontconfig.localFonts 引入本地字体
}
