# nixos-config
Vitus Nixos Config
nixos+hyprland

## Repository layout

```
nixos-config/
├── flake.nix              # 主配置文件（Flakes 入口点）
├── flake.lock             # 锁定依赖版本
├── hosts/                 # 主机特定配置
│   ├── Vitus5600/         # 主机 1 配置
│   └── Vitus8500/         # 主机 2 配置
├── modules/               # 系统级模块
│   └── system/
├── users/                 # 用户配置
│   └── vitus/
├── home/                  # Home Manager 模块
│   ├── core.nix           # 核心配置
│   ├── fcitx5/            # 输入法配置
│   ├── programs/          # 程序配置
│   ├── shell/             # Shell 配置
│   └── linux/             # Linux 桌面环境配置
├── overlays/              # 自定义包覆盖
├── secrets/               # SOPS 加密配置
└── README.md
```
用了sop-nix进行密钥加密，不能直接部署。

