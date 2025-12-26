# Vitus's NixOS & Home-Manager Configuration

基于 Flake 的 NixOS 配置，支持多主机和非 NixOS 系统（Ubuntu/WSL）。

## 特性

- **Hyprland** - 现代化 Wayland 窗口管理器
- **Fcitx5 + Rime** - 中文输入法支持
- **Catppuccin Mocha** - 统一的深色主题
- **SOPS-nix** - 安全的密钥管理
- **多主机支持** - Vitus5600 (NVIDIA) / Vitus8500
- **跨平台** - 支持 NixOS、Ubuntu、WSL

## 目录结构

```
~/.config/home-manager/
├── flake.nix              # Flake 入口，定义所有配置输出
├── flake.lock             # 依赖版本锁定
├── .sops.yaml             # SOPS 密钥配置
│
├── hosts/                 # 主机特定配置
│   ├── Vitus5600/         # 桌面工作站 (Ryzen 5600 + NVIDIA)
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── Vitus8500/         # 辅助主机
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/               # NixOS 系统模块
│   └── system/
│       ├── system.nix     # 核心系统配置
│       ├── packages.nix   # 系统级软件包
│       └── nvidia.nix     # NVIDIA 驱动配置
│
├── users/                 # 用户配置
│   └── vitus/
│       ├── home.nix       # Home-Manager 入口
│       └── nixos.nix      # NixOS 用户配置
│
├── home/                  # Home-Manager 模块
│   ├── core.nix           # 核心配置
│   ├── fcitx5/            # 中文输入法
│   ├── shell/             # Shell 环境
│   │   ├── zsh.nix        # Zsh + Powerlevel10k
│   │   ├── starship.nix   # Starship 提示符
│   │   └── ...
│   ├── programs/          # 应用程序配置
│   │   ├── common.nix     # 通用工具
│   │   ├── git.nix
│   │   ├── browsers.nix
│   │   ├── terminals.nix
│   │   └── ...
│   └── linux/gui/         # 桌面环境
│       ├── base/          # 主题、XDG、桌面组件
│       └── hyprland/      # Hyprland 配置
│
├── overlays/              # Nix 包覆盖
│   └── fcitx5/            # Rime 输入法数据
│
└── secrets/               # SOPS 加密的密钥
    └── secrets.yaml
```

## 快速开始

### NixOS 主机

```bash
# 首次部署（指定主机名）
sudo nixos-rebuild switch --flake ~/.config/home-manager#Vitus5600

# 如果已将配置链接到 /etc/nixos
sudo nixos-rebuild switch

# 更新依赖并重建
nix flake update
sudo nixos-rebuild switch
```

### 非 NixOS 系统（Ubuntu/WSL）

```bash
# 1. 安装 Nix
curl -L https://nixos.org/nix/install | sh

# 2. 启用 Flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 3. 安装 Home-Manager
nix run home-manager/release-25.11 -- init

# 4. 部署配置
home-manager switch --flake ~/.config/home-manager#vitus@ubuntu  # Ubuntu/Debian
home-manager switch --flake ~/.config/home-manager#vitus@wsl     # WSL
```

## 可用配置

| 配置名 | 类型 | 说明 |
|--------|------|------|
| `Vitus5600` | NixOS | 桌面工作站，带 NVIDIA GPU |
| `Vitus8500` | NixOS | 辅助主机 |
| `vitus@ubuntu` | Home-Manager | Ubuntu/Debian CLI 环境 |
| `vitus@wsl` | Home-Manager | WSL 专用配置 |

## 密钥管理

本配置使用 [SOPS-nix](https://github.com/Mic92/sops-nix) 管理敏感信息。

### NixOS 系统

密钥自动从 `/run/secrets/` 加载：
- `anthropic_auth_token`
- `anthropic_base_url`
- `github_token`

### 非 NixOS 系统
#### 完善代理 
nix是用client-server的模式，命令行的代理不是nix-daemon的代理
nix-daemon 代理设置 ：
```
# 1. 创建配置文件夹（如果不存在）
sudo mkdir -p /etc/systemd/system/nix-daemon.service.d/

# 2. 直接写入代理配置
printf "[Service]
Environment=\"http_proxy=http://127.0.0.1:7897\"
Environment=\"https_proxy=http://127.0.0.1:7897\"
Environment=\"all_proxy=http://127.0.0.1:7897\"
" | sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf

# 3. 重新加载配置并重启 Nix 服务
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon
```

创建 `~/.secrets.env` 文件（不要提交到 Git）：

```bash
export ANTHROPIC_AUTH_TOKEN="your-token"
export ANTHROPIC_BASE_URL="https://anyrouter.top"
export GITHUB_TOKEN="your-token"
```

## 主要软件栈

### 桌面环境
- **WM**: Hyprland (Wayland)
- **登录管理器**: Ly
- **状态栏**: Waybar
- **启动器**: Anyrun
- **通知**: Mako
- **终端**: Alacritty / Kitty / WezTerm

### 开发工具
- **编辑器**: VSCode, Cursor, Zed, Neovim
- **语言**: Rust (rustup), Python, Node.js
- **Shell**: Zsh + Powerlevel10k + Antidote

### 中文支持
- **输入法**: Fcitx5 + Rime
- **字体**: Noto CJK, FiraCode Nerd Font

## 常用命令

```bash
# 检查配置语法
nix flake check

# 构建但不切换
nixos-rebuild build --flake .#Vitus5600

# 查看配置差异
nixos-rebuild build --flake .#Vitus5600 && nvd diff /run/current-system result

# 清理旧版本
sudo nix-collect-garbage -d

# 编辑加密密钥
sops secrets/secrets.yaml
```

## 添加新主机

1. 创建主机配置：
```bash
mkdir -p hosts/NewHost
# 在目标机器上生成硬件配置
nixos-generate-config --show-hardware-config > hosts/NewHost/hardware-configuration.nix
```

2. 创建 `hosts/NewHost/default.nix`：
```nix
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "NewHost";
  # 主机特定配置...
}
```

3. 在 `flake.nix` 中添加配置输出

## 注意事项

- 使用了 SOPS-nix 加密密钥，无法直接克隆部署
- 需要配置自己的 Age 密钥才能解密 `secrets/secrets.yaml`
- Hyprland 配置针对特定显示器，可能需要调整 `home/linux/gui/hyprland/conf/`

## 参考

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [SOPS-nix](https://github.com/Mic92/sops-nix)
