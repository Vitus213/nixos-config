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
                hardware.bluetooth.enable = true;
            hardware.bluetooth.powerOnBoot = true;
                       services.tailscale.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    tailscale
    # 工具 (Tools)
    appimage-run # 运行 AppImage 格式应用程序的工具。

    cpufrequtils # CPU 频率调节工具。
    curl # 命令行数据传输工具，支持多种协议。
    git # 分布式版本控制系统。

    pciutils # 显示 PCI 设备信息的工具。
    rofi # 窗口切换器、应用程序启动器和 dmenu 替代品。

    wget # 命令行文件下载工具。

    zoxide # 更智能的 `cd` 命令，通过记忆常用目录来提高效率。

    # 系统监控 (Monitor)
    (btop.override {
      cudaSupport = true;
      rocmSupport = true;
    }) # 一个资源监视器，支持 CUDA 和 ROCm (GPU)。

    fastfetch # 快速、可定制的系统信息工具。

    nvtopPackages.full # NVIDIA GPU 监视工具的完整包。
    atop # 高级性能监视器，可记录系统活动。

    hyfetch # 一个美观的 `neofetch` 替代品，支持更多定制。
    ipfetch # 显示 IP 地址和相关信息的工具。
    neofetch # 命令行系统信息工具，以艺术字体显示系统标志。

    # Shell 工具 (Shell)

    lsd # `ls` 命令的彩色化和图标化替代品。

    zip # 压缩和解压缩文件 (已合并到工具)。
    bind # DNS 实用程序 (此处的 bind 通常指 dnsutils, 用于查询DNS)。

    # 硬件相关工具 (Hardware)
    cpufetch # 快速显示 CPU 信息的工具。
    cpuid # 显示详细 CPU 信息的工具。
    cpu-x # GUI CPU 信息工 smartmontools # 监控硬盘 SMART 状态的工具。
    light # 命令行背光控制工具。
    lm_sensors # 监控硬件传感器 (CPU 温度、风扇速度等) 的工具。
    lshw # 硬件列表工具。

    # 终端模拟器 (Terminals)
    kitty # 快速、功能丰富的 GPU 加速终端模拟器。
    wezterm # 跨平台、GPU 加速的终端模拟器。

    which # 用于查找命令路径的工具。
    tree # 以树状图列出目录内容的工具。

  ];

}
