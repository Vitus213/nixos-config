{ lib, pkgs, catppuccin-bat, ... }: {
  home.packages = with pkgs; [
    # 媒体与图像应用程序 (Media)
    loupe # GNOME 图像查看器 (现代化替代品)。
    eog # GNOME 图像查看器 (Eye of GNOME)。
    feh # 轻量级图像查看器，也可作为壁纸设置工具 (常用于 X11，但在 Wayland 下也可查看图像)。
    # (mpv.override { scripts = [ mpvScripts.mpris ]; }) # MPV 媒体播放器，带有 MPRIS 脚本支持 (用于集成媒体控制)。
    vlc # 流行的跨平台媒体播放器。
    activitywatch # 自动时间追踪器。
    qbittorrent-enhanced # qBittorrent 增强版。

    # 网络 (Net)
    clash-verge-rev # Clash Verge 的复刻版本，代理客户端。
    flclash # 可能与 Clash 相关的工具。

    # 社交 (Social)
    ente-auth # Ente Photos 的认证客户端。

    # 办公与官方工具 (Office & Official Tools)
    typora # Markdown 编辑器。
    wpsoffice-cn # 金山 WPS Office 中文版。

    # Web 开发相关
    nodejs_24 # Node.js 运行时 (版本 24)。
    pnpm # 快速、磁盘效率高的 Node.js 包管理器。

    # 排版 (Typst)
    typst # 新一代科学排版语言和编译器。
    tinymist # Typst 的 LSP 服务器。
    vscode-extensions.myriad-dreamin.tinymist # VSCode Typst 扩展。
    pandoc # 通用文档转换器。
    nixfmt-classic

    # 开发工具 (Development Tools)
    rustup # Rust 工具链安装程序。
    llvmPackages_latest.libcxxClang # Clang 的 C++ 标准库。
    llvmPackages_latest.clang-tools # Clang 相关的开发工具 (如 linter, formatter)。

    cmake # 跨平台构建系统生成器。
    obsidian

    #hyprland stuff
    wlogout
    swww
    grim
    slurp
    swappy
    wl-clipboard
    pamixer
    mpc
    mpd
    ncmpcpp
    cava
    calendar-cli
    xfce.thunar

  ];

  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = "mouse on";
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin-mocha";
      };
      themes = {
        # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
        catppuccin-mocha = {
          src = catppuccin-bat;
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };

    btop.enable = true; # replacement of htop/nmon
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    ssh = {
      enable = true;
      matchBlocks = {
        # 你的 "Host 5600" 配置
        "5600" = { # 这里的键就是 Host 别名
          hostname = "100.64.0.47";
          user = "vitus";
          # 你也可以在这里添加其他针对 5600 的设置
          # identityFile = "~/.ssh/id_rsa_5600";
        };

        # 你的 "Host Nixos" 配置
        "Nixos" = {
          hostname = "100.64.0.41";
          user = "vitus";
        };
      };
    };
    aria2.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  services = {
    syncthing.enable = true;

    # auto mount usb drives
    udiskie.enable = true;
  };
}
