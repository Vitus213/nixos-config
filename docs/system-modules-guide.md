# NixOS 配置模块详解

**配置仓库**: nixos-config
**最后更新**: 2024-12-27
**作者**: Vitus

本文档详细介绍此 NixOS 配置中各个模块的作用、原理和配置方式。

---

## 目录

1. [配置结构概览](#配置结构概览)
2. [系统级模块 (modules/system)](#系统级模块-modulessystem)
3. [Home Manager 模块 (home/)](#home-manager-模块-home)
4. [桌面环境模块](#桌面环境模块)
5. [关键服务详解](#关键服务详解)
6. [故障排查指南](#故障排查指南)

---

## 配置结构概览

```
nixos-config/
├── flake.nix                  # Flake 入口，定义系统配置
├── hosts/                     # 主机特定配置
│   ├── Vitus5600/            # AMD Ryzen 5 5600 工作站
│   └── Vitus8500/            # AMD Ryzen 7 8500 笔记本
├── modules/
│   ├── system/               # NixOS 系统级模块
│   ├── darwin/               # macOS 系统级模块
│   └── desktop/              # 桌面环境模块
├── home/                      # Home Manager 用户级配置
│   ├── linux/                # Linux 特定配置
│   ├── programs/             # 应用程序配置
│   ├── shell/                # Shell 环境配置
│   └── fcitx5/               # 输入法配置
├── users/                     # 用户配置入口
└── overlays/                  # Nix overlays
```

---

## 系统级模块 (modules/system)

### 1. default.nix - 系统配置入口

**位置**: `modules/system/default.nix`

**作用**：
- 聚合所有系统级模块
- 配置 home-manager 集成
- 传递全局参数 (inputs, username, hostname, unstable)

**关键配置**：

```nix
home-manager = {
  useGlobalPkgs = true;        # 使用系统 nixpkgs
  useUserPackages = true;      # 安装到用户环境

  # 传递参数给 home-manager
  extraSpecialArgs = inputs // {
    inherit unstable username hostname inputs;
  };

  users.${username} = import ../../users/${username}/nixos.nix;
};
```

**为什么需要 extraSpecialArgs？**
- home-manager 默认无法访问 flake inputs
- 需要显式传递 inputs 才能在 home-manager 中使用 `inputs.hyprland`
- 传递 unstable 可以使用最新软件包

---

### 2. packages.nix - 系统软件包管理

**位置**: `modules/system/packages.nix`

**作用**：
- 定义系统级安装的软件包
- 配置 Hyprland 窗口管理器
- 配置 ly 显示管理器

**关键服务**：

#### Hyprland 配置

```nix
programs.hyprland = {
  enable = true;
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
};
```

**原理**：
- 使用 flake input 的 Hyprland 而非 nixpkgs 版本
- `portalPackage`: 配置 xdg-desktop-portal-hyprland 后端
- portal 用于沙盒应用与系统通信（文件选择、截图等）

#### ly 显示管理器

```nix
services.displayManager.ly = {
  enable = true;
  package = pkgs.ly;
  settings = {
    animation = "matrix";
  };
};
```

**ly 的作用**：
- 轻量级 TUI 显示管理器
- 替代 GDM/SDDM，资源占用更少
- 负责启动 Wayland compositor (Hyprland)

---

### 3. sops.nix - 密钥管理

**位置**: `modules/system/sops.nix`

**作用**：
- 使用 sops-nix 加密管理敏感信息
- 配置 GitHub token 避免 API rate limit
- 配置其他服务密钥

**关键配置**：

```nix
sops.secrets.github_token = {
  owner = username;
  group = "users";
  mode = "0400";  # 只读权限
};

# 在登录时设置 GITHUB_TOKEN 和 NIX_CONFIG
environment.extraInit = ''
  if [ -f "${config.sops.secrets.github_token.path}" ]; then
    export GITHUB_TOKEN="$(cat ${config.sops.secrets.github_token.path})"
    export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN"
  fi
'';
```

**为什么用 extra-access-tokens？**
- `access-tokens` 通过环境变量设置时不生效
- `extra-access-tokens` 是追加配置项，设计用于运行时添加
- 参考：[NixOS/nix#6536](https://github.com/NixOS/nix/issues/6536)

**密钥存储位置**：
- 加密文件：`secrets/secrets.yaml`
- 运行时解密到：`/run/secrets/github_token`
- 使用 age 加密，私钥在 `~/.ssh/id_rsa`

---

### 4. system.nix - 系统基础配置

**位置**: `modules/system/system.nix`

**作用**：
- 配置系统时区、语言、键盘布局
- 配置网络、声音、打印服务
- 配置系统服务（Docker、虚拟化等）

**关键配置**：

#### 时区和本地化

```nix
time.timeZone = "Asia/Shanghai";
i18n = {
  defaultLocale = "en_US.UTF-8";
  extraLocaleSettings = {
    LC_TIME = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
  };
};
```

#### PipeWire 音频

```nix
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;  # PulseAudio 兼容层
  jack.enable = true;   # JACK 兼容层
};
```

**PipeWire vs PulseAudio**：
- PipeWire 是现代音频服务器，低延迟
- 兼容 PulseAudio 和 JACK 应用
- 支持专业音频工作流

---

### 5. nvidia.nix - NVIDIA 驱动配置

**位置**: `modules/system/nvidia.nix`

**作用**：
- 配置 NVIDIA 专有驱动
- 配置 PRIME (混合显卡)
- 配置 Wayland 支持

**关键配置**：

```nix
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
  modesetting.enable = true;        # Wayland 必需
  powerManagement.enable = false;
  open = false;                     # 使用专有驱动
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};

# Wayland 环境变量
environment.sessionVariables = {
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  WLR_NO_HARDWARE_CURSORS = "1";  # 避免光标问题
};
```

---

## Home Manager 模块 (home/)

### 1. fcitx5/ - 输入法配置

**位置**: `home/fcitx5/default.nix`

**作用**：
- 配置 fcitx5 输入法框架
- 配置 Rime 输入引擎
- 配置 Wayland 下的输入法行为

**关键配置**：

```nix
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5.waylandFrontend = true;  # 启用 Wayland 支持
  fcitx5.addons = with pkgs; [
    fcitx5-rime           # Rime 引擎
    qt6Packages.fcitx5-configtool
    fcitx5-gtk            # GTK IM 模块
  ];
};
```

#### GTK 配置文件（而非环境变量）

```nix
xdg.configFile = {
  "gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-im-module=fcitx
  '';
  "gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-im-module=fcitx
  '';
};
```

**为什么不设置 GTK_IM_MODULE？**
- 环境变量会影响**所有** GTK 应用（包括 Wayland 原生）
- Wayland 应用应使用 text-input-v3 协议
- 配置文件只影响 X11/XWayland 应用

**参考**：[fcitx5 Wayland 文档](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)

---

### 2. linux/gui/hyprland/ - Hyprland 配置

**位置**: `home/linux/gui/hyprland/hyprland.nix`

**作用**：
- 配置 Hyprland 窗口管理器
- 启用 systemd 集成
- 配置 Hyprland 会话环境

**关键配置**：

```nix
wayland.windowManager.hyprland = {
  enable = true;
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  # systemd 集成
  systemd = {
    enable = true;
    variables = [ "--all" ];  # 导入所有环境变量
  };
};
```

**systemd 集成的作用**：
- 创建 `hyprland-session.target`
- 导入 Hyprland 设置的环境变量到 systemd
- 让 systemd 用户服务能访问 `WAYLAND_DISPLAY` 等变量

#### 配置文件结构

```
~/.config/hypr/
└── configs/  (符号链接到仓库)
    ├── exec.conf           # 启动脚本
    ├── fcitx5.conf         # 输入法相关
    ├── keybindings.conf    # 快捷键
    ├── settings.conf       # 窗口、动画等
    └── windowrules.conf    # 窗口规则
```

---

### 3. linux/gui/hyprland/xdg.nix - XDG Portal 配置

**位置**: `home/linux/gui/hyprland/xdg.nix`

**作用**：
- 配置 xdg-desktop-portal
- 设置默认应用程序
- 配置 MIME 类型关联

**关键配置**：

```nix
xdg.portal = {
  enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk  # 文件选择器等
  ];
  # xdg-desktop-portal-hyprland 在系统级配置
};
```

**为什么只配置 portal-gtk？**
- `xdg-desktop-portal-hyprland` 已在 `modules/system/packages.nix` 配置
- 避免重复安装导致冲突
- portal-gtk 提供通用 UI 功能（文件选择器、打印等）

---

### 4. shell/zsh.nix - Shell 环境配置

**位置**: `home/shell/zsh.nix`

**作用**：
- 配置 zsh shell
- 配置环境变量
- 配置 shell 插件和主题

**关键配置**：

```nix
sessionVariables = {
  # 代理设置
  http_proxy = "http://127.0.0.1:7897";
  https_proxy = "http://127.0.0.1:7897";
  all_proxy = "socks5://127.0.0.1:7897";

  # 输入法（只设置 XMODIFIERS，不设置 GTK/QT_IM_MODULE）
  XMODIFIERS = "@im=fcitx";
};
```

**为什么只设置 XMODIFIERS？**
- `GTK_IM_MODULE` 和 `QT_IM_MODULE` 会强制所有应用使用 fcitx IM 模块
- Wayland 应用应使用 text-input-v3 协议
- `XMODIFIERS` 只影响 XWayland 应用的 XIM 协议

---

## 桌面环境模块

### Hyprland 窗口管理器

**类型**: Wayland compositor
**配置**: `modules/system/packages.nix` + `home/linux/gui/hyprland/`

**特点**：
- 动态平铺窗口管理器
- 基于 wlroots
- 支持动画、模糊、圆角等特效
- 使用 Hyprland 配置语言

**依赖服务**：
- `waybar`: 状态栏
- `hypridle`: 空闲管理（自动锁屏）
- `hyprlock`: 屏幕锁
- `xdg-desktop-portal-hyprland`: 截图、屏幕共享

---

## 关键服务详解

### 1. xdg-desktop-portal - 沙盒应用通信桥梁

**什么是 portal？**

xdg-desktop-portal 是 Freedesktop 标准的沙盒应用通信桥梁，让应用能够安全地访问系统功能。

**架构**：

```
应用程序 (VSCode, Firefox, Chrome)
    ↓ D-Bus: org.freedesktop.portal.Desktop
xdg-desktop-portal (主服务)
    ↓ 根据功能分发
    ├── xdg-desktop-portal-hyprland
    │   ├── Screenshot (截图)
    │   ├── ScreenCast (屏幕共享)
    │   └── GlobalShortcuts
    │
    └── xdg-desktop-portal-gtk
        ├── FileChooser (文件选择器)
        ├── AppChooser (应用选择器)
        ├── Print (打印)
        └── Settings (系统设置)
```

**主要功能**：

| Portal 接口 | 功能 | 使用场景 |
|------------|------|---------|
| FileChooser | 文件选择对话框 | 打开/保存文件 |
| Screenshot | 截图 | 截图工具、应用内截图 |
| ScreenCast | 屏幕录制/共享 | Zoom、Teams、OBS |
| Notification | 桌面通知 | 应用通知 |
| OpenURI | 打开 URL | 默认浏览器 |
| Settings | 系统设置 | 主题、字体、颜色 |

**为什么 Wayland 需要 portal？**

X11 时代，任何应用都能：
- 随意截取任何窗口
- 读取其他窗口的键盘输入
- 访问任意文件

Wayland 设计原则：应用隔离
- 应用看不到其他应用
- 不能随意截屏
- 必须通过 portal 请求权限

**具体例子**：

```
VSCode 想打开文件：
1. VSCode 调用 org.freedesktop.portal.FileChooser.OpenFile
2. xdg-desktop-portal 转发给 portal-gtk
3. GTK 文件选择器弹出（由系统控制）
4. 用户选择文件
5. portal 返回文件路径
6. VSCode 只能访问用户选择的文件

好处：
- VSCode 无法扫描整个文件系统
- 即使被攻击，攻击者也只能访问用户选择的文件
```

**配置文件**：

```ini
# ~/.config/xdg-desktop-portal/hyprland-portals.conf
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.FileChooser=gtk
```

**参考**：
- [xdg-desktop-portal 官方文档](https://flatpak.github.io/xdg-desktop-portal/)
- [ArchWiki - XDG Desktop Portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal)

---

### 2. PipeWire - 现代音频服务器

**位置**: `modules/system/system.nix`

**作用**：
- 统一音频和视频流处理
- 替代 PulseAudio 和 JACK
- 低延迟、专业音频支持

**配置**：

```nix
services.pipewire = {
  enable = true;
  alsa = {
    enable = true;
    support32Bit = true;
  };
  pulse.enable = true;  # PulseAudio 兼容
  jack.enable = true;   # JACK 兼容
};
```

**为什么用 PipeWire？**
- 低延迟（音频处理 < 5ms）
- 兼容 PulseAudio 应用
- 支持蓝牙 aptX/LDAC 高清编码
- 支持屏幕录制音频捕获

---

### 3. systemd 用户服务

**位置**: home-manager 自动生成
**目录**: `~/.config/systemd/user/`

**关键 target**：

```
graphical-session.target
├── hyprland-session.target
├── xdg-desktop-portal.service
├── waybar.service
├── hypridle.service
└── fcitx5-daemon.service
```

**服务启动时序问题**：

问题：graphical-session.target 在 WAYLAND_DISPLAY 设置前激活

解决：在 Hyprland 启动后手动重启服务

```bash
# home/linux/gui/hyprland/conf/exec.conf
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY ...
exec-once = systemctl --user restart xdg-desktop-portal-gtk.service ...
exec-once = sleep 1 && systemctl --user restart waybar.service ...
```

**参考**：`docs/troubleshooting-2024-12-27.md` - 问题九

---

### 4. Nix 配置优先级

**配置来源**（从低到高）：

1. `/etc/nix/nix.conf` (系统级)
2. `~/.config/nix/nix.conf` (用户级)
3. `NIX_USER_CONF_FILES` 环境变量
4. `NIX_CONFIG` 环境变量
5. 命令行参数 (`--option`)

**extra- 前缀**：

用于追加而非替换列表配置：

```bash
# nix.conf
substituters = a b

# 使用 extra- 追加
extra-substituters = c d

# 结果: substituters = a b c d
```

**常见 extra- 配置**：
- `extra-substituters`
- `extra-trusted-public-keys`
- `extra-access-tokens`  # 用于 GitHub token

**参考**：`docs/troubleshooting-2024-12-27.md` - Nix 配置系统详解

---

## 故障排查指南

### 常用命令

```bash
# systemd 服务
systemctl --user status <service>
systemctl --user list-units --failed
systemd-analyze blame --user
systemd-analyze critical-chain --user <service>

# 日志
journalctl --user -b
journalctl --user -u <service>
journalctl --user -b | grep -i <keyword>

# Hyprland
hyprctl clients
hyprctl layers
hyprctl monitors

# portal
busctl --user list | grep portal
busctl --user introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop

# 环境变量
systemctl --user show-environment
env | grep -E "IM_MODULE|WAYLAND|DISPLAY"

# Nix
nix config show
nix flake metadata
```

### 常见问题

| 问题 | 诊断 | 解决方案 |
|------|------|---------|
| waybar 启动慢 | `journalctl --user -u waybar` | 检查 portal 服务，参考问题九 |
| 输入法候选框位置错误 | 检查 IM_MODULE 环境变量 | 移除 GTK_IM_MODULE，参考问题八 |
| 截图不工作 | `systemctl --user status xdg-desktop-portal-hyprland` | 重启 portal 服务 |
| 音频无输出 | `systemctl --user status pipewire` | 检查 PipeWire 服务 |

### 详细故障排查文档

参见 `docs/troubleshooting-2024-12-27.md`，包含：
- 9 个常见问题的完整诊断过程
- 根本原因分析
- 详细解决方案
- 调试命令
- 参考资料链接

---

## 参考资料

### 官方文档
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [xdg-desktop-portal 文档](https://flatpak.github.io/xdg-desktop-portal/)

### 社区资源
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [r/NixOS](https://www.reddit.com/r/NixOS/)

### 本配置相关
- [troubleshooting-2024-12-27.md](./troubleshooting-2024-12-27.md) - 故障排查指南
- [GitHub 仓库](https://github.com/yourusername/nixos-config) - 配置源码
