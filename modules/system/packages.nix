{ pkgs, inputs, host, ... }: {

  programs = {
    hyprland = {
      enable = true;
      withUWSM = false;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; # hyprland-git
      #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; #xdph-git
      portalPackage = pkgs.xdg-desktop-portal-hyprland; # xdph none git
      xwayland.enable = true;
    };
    zsh.enable = true;
    firefox.enable = true;
    #在home-manager中启用waybar
    #waybar.enable = true;
    hyprlock.enable = true;
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    tmux.enable = true;
    nm-applet.indicator = true;
    neovim = {
      enable = true;
      defaultEditor = false;
    };
    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];

  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [

    # Hyprland
    hypridle # Hyprland 的空闲管理工具，用于屏幕锁定、关闭显示器等。
    hyprpolkitagent # Hyprland 的 Polkit 代理，用于处理需要提升权限的操作。
    pyprland # Hyprland 的 Python 扩展和插件框架。
    hyprlang # Hyprland 的配置文件语言工具。
    hyprshot # Hyprland 的屏幕截图工具。
    hyprcursor # Hyprland 的鼠标光标主题管理工具。
    mesa # 开源图形库，提供 OpenGL 和 Vulkan 支持，对 Wayland 环境至关重要。
    nwg-displays # NWG 套件中的显示器配置工具，适用于 Wayland。
    nwg-look # NWG 套件中的 GTK 主题和图标配置工具。
    waypaper # Wayland 桌面环境的壁纸工具。
    hyprland-qt-support # 为 Hyprland 提供更好的 Qt 应用程序支持。

    # 工具 (Tools)
    appimage-run # 运行 AppImage 格式应用程序的工具。
    bc # 命令行计算器。
    brightnessctl # 命令行亮度控制工具。
    btrfs-progs # Btrfs 文件系统工具。
    cargo # Rust 包管理器和构建系统。
    clang # Clang 编译器前端，支持 C, C++, Objective-C 等。
    cmake # 跨平台构建系统生成器。
    cliphist # Wayland 剪贴板历史记录管理器。
    cpufrequtils # CPU 频率调节工具。
    curl # 命令行数据传输工具，支持多种协议。
    ffmpeg # 音视频处理工具，用于转换、录制、流媒体等。
    fd # 更快更用户友好的 `find` 替代品。
    findutils # 包含 `find`, `xargs` 等核心文件查找工具。
    file-roller # GNOME 档案管理器，支持多种压缩格式。
    glib # GNOME 核心库，许多 GTK 应用程序的依赖。
    gsettings-qt # 允许 Qt 应用程序使用 GSettings 配置系统。
    git # 分布式版本控制系统。
    gcc # GNU 编译器集合，支持 C, C++, Fortran 等。
    gnumake # GNU Make 工具，用于自动化编译和构建过程。
    grim # Wayland 桌面环境的命令行截图工具。
    grimblast # `grim` 的扩展，提供更方便的截图区域选择和编辑功能。
    gtk-engine-murrine # GTK 主题引擎，用于渲染 Murrine 主题。
    imagemagick # 强大的图像处理命令行工具集。
    killall # 根据进程名终止进程。
    libappindicator # 支持应用程序指示器图标的库。
    libnotify # 发送桌面通知的库。
    networkmanagerapplet # NetworkManager 的系统托盘小程序，用于网络连接管理。
    openssl # SSL/TLS 协议的开源实现，提供加密功能。
    pciutils # 显示 PCI 设备信息的工具。
    pamixer # 命令行 PulseAudio 混合器。
    pavucontrol # PulseAudio 音量控制 GUI。
    playerctl # 命令行媒体播放器控制工具。
    rofi # 窗口切换器、应用程序启动器和 dmenu 替代品。
    slurp # Wayland 桌面环境的命令行区域选择工具 (用于截图等)。
    swappy # Wayland 桌面环境的截图编辑工具。
    swaynotificationcenter # Wayland 桌面环境的通知中心。
    swww # Wayland 桌面环境的壁纸管理和设置工具。
    unzip # 解压 `.zip` 文件的工具。
    wallust # 从壁纸生成颜色方案的工具。
    wdisplays # Wayland 桌面环境的显示器配置 GUI。
    wl-clipboard # Wayland 剪贴板命令行工具。
    wlr-randr # Wayland 桌面环境的显示器配置工具。
    wlogout # Wayland 桌面环境的注销菜单。
    wget # 命令行文件下载工具。
    xarchiver # Xfce 档案管理器。
    yad # (Yet Another Dialog) 创建 GTK 对话框的命令行工具。
    yt-dlp # YouTube 下载器 (基于 `youtube-dl` 的分支，功能更强大)。
    zoxide # 更智能的 `cd` 命令，通过记忆常用目录来提高效率。

    # 系统监控 (Monitor)
    (btop.override {
      cudaSupport = true;
      rocmSupport = true;
    }) # 一个资源监视器，支持 CUDA 和 ROCm (GPU)。
    bottom # 跨平台、命令行系统监视器 (Rust 实现)。
    baobab # GNOME 磁盘使用分析器 (也称为 Disk Usage Analyzer)。
    cmatrix # 经典的“黑客帝国”屏幕效果。
    dua # 磁盘使用分析器，更快更易用。
    duf # 磁盘使用情况/免费工具，一个 `df` 替代品。
    cava # 终端音频可视化工具。
    dysk # 另一个磁盘使用分析器。
    gnome-system-monitor # GNOME 系统监视器，提供进程、资源、文件系统信息。
    fastfetch # 快速、可定制的系统信息工具。
    inxi # 功能强大的命令行系统信息脚本。
    lazydocker # 终端中的 Docker GUI 客户端。
    nvtopPackages.full # NVIDIA GPU 监视工具的完整包。
    atop # 高级性能监视器，可记录系统活动。
    gdu # 磁盘使用分析器，比 `du` 更快。
    glances # 跨平台系统监视工具，提供大量信息。
    gping # 带有图形输出的 `ping` 工具。
    htop # 交互式进程查看器和系统监视器。
    hyfetch # 一个美观的 `neofetch` 替代品，支持更多定制。
    ipfetch # 显示 IP 地址和相关信息的工具。
    mission-center # GTK 桌面环境下的系统监视器 (类似于 Windows 任务管理器)。
    neofetch # 命令行系统信息工具，以艺术字体显示系统标志。
    ncdu # 带有 ncurses 界面的磁盘使用分析器。

    # Shell 工具 (Shell)
    eza # 现代、美观、功能丰富的 `ls` 替代品。
    figlet # 生成大型 ASCII 艺术字体的工具。
    jq # 命令行 JSON 处理器。
    lolcat # 给命令行输出添加彩虹色的工具。
    lsd # `ls` 命令的彩色化和图标化替代品。
    oh-my-posh # 跨平台、可高度定制的 Shell 提示符主题引擎。
    pfetch # 极简的系统信息工具。
    ripgrep # 更快、更强大的 `grep` 替代品。
    starship # 极速、跨平台、可定制的 Shell 提示符。
    tldr # 简化版 `man` 页面，提供常用命令示例。
    ugrep # 具有更多功能的 `grep` 替代品。

    # Qt 应用程序主题与集成 (Qt)
    kdePackages.qt6ct # Qt6 配置工具，用于设置 Qt6 应用程序的样式和字体。
    kdePackages.qtwayland # Qt Wayland 插件，确保 Qt 应用程序在 Wayland 下良好运行。
    kdePackages.qtstyleplugin-kvantum # Kvantum Qt 主题引擎插件，提供高级主题功能。
    libsForQt5.qtstyleplugin-kvantum # Qt5 版本的 Kvantum 主题引擎插件。
    libsForQt5.qt5ct # Qt5 配置工具，用于设置 Qt5 应用程序的样式和字体。
    kdePackages.polkit-kde-agent-1 # KDE 的 Polkit 代理，用于处理权限请求。

    # 硬件相关工具 (Hardware)
    cpufetch # 快速显示 CPU 信息的工具。
    cpuid # 显示详细 CPU 信息的工具。
    cpu-x # GUI CPU 信息工具。
    smartmontools # 监控硬盘 SMART 状态的工具。
    light # 命令行背光控制工具。
    lm_sensors # 监控硬件传感器 (CPU 温度、风扇速度等) 的工具。
    lshw # 硬件列表工具。

    # 虚拟化 (VM)
    virt-viewer # 远程桌面查看器，用于 QEMU/KVM 虚拟机。
    libvirt # 虚拟化管理库。

    # 媒体与图像应用程序 (Media)
    loupe # GNOME 图像查看器 (现代化替代品)。
    eog # GNOME 图像查看器 (Eye of GNOME)。
    feh # 轻量级图像查看器，也可作为壁纸设置工具 (常用于 X11，但在 Wayland 下也可查看图像)。
    # (mpv.override { scripts = [ mpvScripts.mpris ]; }) # MPV 媒体播放器，带有 MPRIS 脚本支持 (用于集成媒体控制)。
    vlc # 流行的跨平台媒体播放器。
    obs-studio # 开源的屏幕录制和直播软件。

    # 终端模拟器 (Terminals)
    kitty # 快速、功能丰富的 GPU 加速终端模拟器。
    wezterm # 跨平台、GPU 加速的终端模拟器。

    # 文件压缩与管理 (File Compression & Management)
    # xarchiver 已在 "工具" 分类中，此处不再重复

    # 杂项 (Misc)
    caligula # 命令行工具，用于快速刻录 ISO 到 USB。
    socat # 多功能中继工具，用于建立双向数据流。
    v4l-utils # 用于 Video4Linux 设备 (如摄像头) 的工具。
    yazi # 异步、支持 Vim 键绑定的终端文件管理器 (Rust 实现)。
    which # 用于查找命令路径的工具。
    tree # 以树状图列出目录内容的工具。

    # 必备工具 (Essential Tools - 合并到现有分类)
    zip # 压缩和解压缩文件 (已合并到工具)。
    bind # DNS 实用程序 (此处的 bind 通常指 dnsutils, 用于查询DNS)。
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

    # NVIDIA 相关
    # lshw 已在 "硬件相关工具" 分类中，此处不再重复

  ];

}
