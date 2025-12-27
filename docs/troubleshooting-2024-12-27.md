# NixOS Hyprland 问题排查与修复记录

**日期**: 2025-12-27
**系统**: NixOS 25.11 + Hyprland + ly 显示管理器
**主机**: Vitus5600 (AMD Ryzen 5 5600)

---

## 问题概述

升级到新版本的 NixOS 后，出现以下问题：
1. 无法从 ly 显示管理器进入 Hyprland，只能从 TTY 手动启动
2. 启动时报错 "boost mode is not supported by this processor or SBIOS"
3. 多个 systemd 用户服务启动失败
4. waybar 无法自动启动
5. 鼠标主题未生效
6. fcitx5 配置语法错误
7. nix access-tokens 配置不生效

---

## 问题一：无法从 ly 进入 Hyprland

### 症状
- 从 ly 登录后会话立即关闭（约1秒）
- 只能从 TTY 手动运行 `Hyprland` 进入桌面

### 诊断过程

#### 1. 查看 ly 日志
```bash
systemctl status display-manager.service
journalctl -b -u display-manager.service
```

**关键日志**:
```
14:30:42 ly: session opened for user vitus
14:30:43 ly: session closed for user vitus
```

会话在1秒内就关闭了！

#### 2. 查看 Hyprland 启动日志
```bash
journalctl -b | grep -i hyprland
```

**关键发现**:
```
xsession[2314]: usage: Hyprland [arg [...]]
xsession: Hyprland exit cleanly
```

Hyprland 打印了用法信息并退出，说明启动参数有问题。

#### 3. 检查 Hyprland 版本一致性
```bash
# 检查系统级使用的版本
cat /home/vitus/nixos-config/modules/system/packages.nix | grep hyprland

# 检查 home-manager 使用的版本
cat /home/vitus/nixos-config/home/linux/gui/hyprland/hyprland.nix | grep package
```

**根本原因发现**:
```nix
# packages.nix (系统级) - 使用 flake 的 hyprland
package = inputs.hyprland.packages...hyprland;  # → 0.52.0

# hyprland.nix (home-manager) - 使用 nixpkgs 的 hyprland
package = pkgs.hyprland;  # → 0.52.1
```

**两个版本不匹配！** ly 使用系统级的 `start-hyprland` 启动，但配置是 home-manager 版本的。

### 解决方案

修改 `home/linux/gui/hyprland/hyprland.nix`，统一使用 flake 版本：

```nix
{
  pkgs,
  config,
  hostname,
  inputs,  # 添加 inputs
  ...
}:
let
  # 使用 flake inputs 中的 hyprland，保持与系统级配置一致
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
```

同时确保 `modules/system/default.nix` 中传递了 inputs：

```nix
home-manager = {
  extraSpecialArgs = inputs // {
    inherit unstable username hostname inputs;  # 添加 inputs
  };
};
```

---

## 问题二：xdg-desktop-portal-hyprland 冲突

### 症状
```
pkgs.buildEnv error: two given paths contain a conflicting subpath:
  `.../xdg-desktop-portal-hyprland-1.3.11/...' and
  `.../xdg-desktop-portal-hyprland-1.3.11/...'
```

### 诊断过程

```bash
grep -rn "xdg-desktop-portal-hyprland" --include="*.nix"
```

发现两处安装：
1. `modules/system/packages.nix` - 系统级通过 `programs.hyprland.portalPackage` 安装
2. `home/linux/gui/hyprland/xdg.nix` - home-manager 通过 `extraPortals` 安装

### 解决方案

移除 home-manager 中的重复安装，修改 `home/linux/gui/hyprland/xdg.nix`：

```nix
extraPortals = [
  pkgs.xdg-desktop-portal-gtk  # 只保留 gtk portal
  # xdg-desktop-portal-hyprland 已在系统级配置
];
```

---

## 问题三：多个 systemd 用户服务失败

### 症状
```bash
systemctl --user list-units --failed
```

失败的服务：
- `kdeconnect.service` - "no Qt platform plugin could be initialized"
- `polkit-gnome.service` - "cannot open display:"
- `xdg-desktop-portal-gtk.service` - "cannot open display:"
- `udiskie.service` - "org.freedesktop.UDisks2 was not provided"

### 诊断过程

```bash
# 查看服务依赖关系
systemctl --user list-dependencies hyprland-session.target

# 查看启动时序
journalctl --user -b | grep -E "graphical-session|Reached target"
```

**关键发现**:
```
14:30:42 - Reached target graphical-session.target
14:30:42 - polkit-gnome: cannot open display:
14:30:42 - hypridle was skipped (ConditionEnvironment=WAYLAND_DISPLAY not met)
```

**根本原因**: `graphical-session.target` 在 Hyprland 设置 `WAYLAND_DISPLAY` 之前就被激活了。

### 原理解释

ly 使用 `xsession-wrapper` 启动会话：
1. 检查 `$XDG_CURRENT_DESKTOP` 是否在 systemd-aware 列表中
2. Hyprland 不在列表中，所以启动 `nixos-fake-graphical-session.target`
3. 这触发了 `graphical-session.target`
4. 依赖于 `graphical-session.target` 的服务开始启动
5. 但此时 Hyprland 还没运行，`WAYLAND_DISPLAY` 未设置
6. 服务因为没有显示环境而失败

---

## 问题四：waybar 无法自动启动

### 症状
```bash
systemctl --user status waybar.service
```
```
Active: inactive (dead)
Condition: ConditionEnvironment=WAYLAND_DISPLAY was not met
```

### 解决方案

修改 `home/linux/gui/hyprland/conf/exec.conf`，在 Hyprland 启动后手动导入环境变量并重启服务：

```bash
# 导入环境变量到 systemd user session
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

# 重启依赖 WAYLAND_DISPLAY 的服务
exec-once = systemctl --user restart waybar.service hypridle.service xdg-desktop-portal-hyprland.service
```

---

## 问题五：fcitx5 配置语法错误

### 症状
Hyprland 报错 "config error missing a value"

### 诊断
```bash
cat home/linux/gui/hyprland/conf/fcitx5.conf
```

问题行：
```
windowrule=pseudo,class:^(fcitx)$
```

### 解决方案

Hyprland 新版本使用 `windowrulev2`，且需要空格：

```bash
windowrulev2 = pseudo, class:^(fcitx)$
```

---

## 问题六：鼠标主题未生效

### 症状
鼠标保持原生样式，未应用 catppuccin 主题

### 诊断
```bash
echo "XCURSOR_THEME=$XCURSOR_THEME"
grep -rn "cursors\|pointerCursor" --include="*.nix"
```

发现没有配置 `home.pointerCursor` 或 `catppuccin.cursors`。

### 原理解释

catppuccin 模块中 `catppuccin.enable = true` 只是设置全局默认值，但 **cursors 需要单独启用**：
- `catppuccin.cursors.enable` 默认是 `false`

### 解决方案

修改 `home/linux/gui/base/theme.nix`：

```nix
catppuccin = {
  enable = true;
  flavor = "mocha";
  accent = "pink";

  # 启用 catppuccin 鼠标主题
  cursors = {
    enable = true;
    accent = "pink";
  };
};
```

---

## 问题七：nix access-tokens 不生效

### 症状
```bash
nix config show | grep access
# access-tokens =

nix flake metadata github:NixOS/nixpkgs
# HTTP error 403 - rate limit exceeded
```

### 诊断过程

#### 尝试1：使用 `!include` 指令

```nix
nix.extraOptions = ''
  !include ${config.sops.templates."nix-access-tokens.conf".path}
'';
```

**失败原因**:
1. `''` 多行字符串会添加缩进，导致文件内容变成 `          access-tokens = ...`
2. `nix config show` 显示 `access-tokens = \`（有反斜杠）

#### 尝试2：使用单行字符串

```nix
nix.extraOptions = "!include ${path}";
```

**结果**: `nix config show` 显示 `access-tokens =`（空值）

#### 尝试3：测试 nix 配置

```bash
# 创建测试配置
mkdir -p /tmp/nixtest
echo 'access-tokens = github.com=test123' > /tmp/nixtest/nix.conf
NIX_CONF_DIR=/tmp/nixtest nix config show | grep access
# access-tokens =
```

**发现**: 即使直接配置也显示为空！这是 **nix 出于安全考虑不显示 access-tokens 的值**。

#### 尝试4：使用 netrc 文件

```nix
nix.extraOptions = ''
  netrc-file = /etc/nix/netrc
'';
```

仍然 403 错误。

### 根本原因

根据 [NixOS/nix#6536](https://github.com/NixOS/nix/issues/6536)：
- nix 的 `!include` 指令对 `access-tokens` 不完全支持
- 无法从文件动态读取 access-tokens

### 最终解决方案

使用环境变量方式，**关键是使用 `extra-access-tokens` 而不是 `access-tokens`**：

```nix
config = lib.mkIf cfg.enable {
  sops.secrets.github_token = {
    owner = username;
    group = "users";
    mode = "0400";
  };

  # 在用户登录时设置环境变量
  # 注意：必须使用 extra-access-tokens 而不是 access-tokens
  # access-tokens 通过环境变量设置时不生效，这是 nix 的已知限制
  environment.extraInit = ''
    if [ -f "${config.sops.secrets.github_token.path}" ]; then
      export GITHUB_TOKEN="$(cat ${config.sops.secrets.github_token.path})"
      export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN"
    fi
  '';
};
```

**为什么是 `extra-access-tokens` 而不是 `access-tokens`？**

- `access-tokens` 在 nix.conf 中是主配置项，通过 `NIX_CONFIG` 环境变量设置时可能被忽略
- `extra-access-tokens` 是追加配置项，专门用于在运行时添加额外的 tokens，与环境变量配合更好

**测试方法**:
```bash
# 手动设置测试
export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN"
nix flake metadata github:NixOS/nixpkgs --refresh

# 验证 - 如果能成功获取 metadata 而不是 403 错误，说明配置生效
```

---

## Nix 配置系统详解

### 配置来源与优先级

Nix 从以下位置读取配置，**后面的配置会覆盖前面的配置**：

| 优先级 | 来源 | 说明 |
|--------|------|------|
| 1 (最低) | `/etc/nix/nix.conf` | 系统级配置，由 NixOS 模块生成 |
| 2 | `~/.config/nix/nix.conf` | 用户级配置 (XDG 目录) |
| 3 | `NIX_USER_CONF_FILES` | 环境变量指定的配置文件 |
| 4 | `NIX_CONFIG` | 环境变量中的内联配置 |
| 5 (最高) | 命令行参数 | 如 `--option name value` |

### NIX_CONFIG 环境变量

**什么是 NIX_CONFIG？**

`NIX_CONFIG` 是一个特殊的环境变量，允许你在不修改配置文件的情况下传递 nix 配置。

```bash
# 单行配置
export NIX_CONFIG="max-jobs = 4"

# 多行配置（用换行符分隔）
export NIX_CONFIG="max-jobs = 4
substituters = https://cache.nixos.org"
```

**工作原理**：
- nix 会将 `NIX_CONFIG` 的内容当作配置文件来解析
- 每一行格式为 `name = value`
- 配置会覆盖 `nix.conf` 中的同名设置

**官方文档描述**:
> "NIX_CONFIG applies settings from Nix configuration from the environment. The content is treated as if it was read from a Nix configuration file. Settings are separated by the newline character."

### NIX_CONFIG 与 nix-daemon 的关系

**重要限制**:
> "Values loaded in [nix.conf] are not forwarded to the Nix daemon. The client assumes that the daemon has already loaded them."

这意味着：
1. 系统级 `/etc/nix/nix.conf` 的值不会从客户端转发到 daemon
2. daemon 使用自己加载的配置
3. `NIX_CONFIG` 在 daemon 模式下的行为取决于具体设置

对于 `access-tokens`：
- 这是 **客户端设置**，用于获取 flake inputs
- 不需要 daemon 知道这个值
- 通过 `NIX_CONFIG` 设置可以正常工作

### extra- 前缀的含义

对于接受列表值的配置项，可以使用 `extra-` 前缀来**追加**而不是替换：

```bash
# nix.conf 中
substituters = a b

# 使用 extra- 追加
extra-substituters = c d

# 最终结果: substituters = a b c d
```

**常见的 extra- 配置项**：
- `extra-substituters` - 追加二进制缓存
- `extra-trusted-public-keys` - 追加信任的公钥
- `extra-trusted-users` - 追加信任的用户
- `extra-access-tokens` - 追加访问令牌
- `extra-experimental-features` - 追加实验性功能

**为什么使用 extra-access-tokens 而不是 access-tokens？**

```bash
# 这样可能不生效
export NIX_CONFIG="access-tokens = github.com=token"

# 这样可以正常工作
export NIX_CONFIG="extra-access-tokens = github.com=token"
```

原因：
1. `access-tokens` 是主配置项，在 `NIX_CONFIG` 中设置时可能与其他配置源冲突
2. `extra-access-tokens` 是追加配置项，设计用于在运行时添加额外的 tokens
3. `extra-` 前缀的配置项更适合与环境变量配合使用

### access-tokens 配置格式

```
access-tokens = host1=token1 host2=token2
```

**各平台格式**：
- **GitHub**: `github.com=<Personal-Access-Token>`
- **GitLab (PAT)**: `gitlab.com=PAT:<token>`
- **GitLab (OAuth2)**: `gitlab.com=OAuth2:<token>`

**带路径的 token**（限制到特定组织/仓库）：
```
access-tokens = github.com/myorg=token123
```

### 相关环境变量汇总

| 变量 | 作用 |
|------|------|
| `NIX_CONFIG` | 内联 nix 配置 |
| `NIX_CONF_DIR` | 指定 nix.conf 目录 (覆盖 /etc/nix) |
| `NIX_USER_CONF_FILES` | 用户配置文件列表 (: 分隔) |
| `NIX_REMOTE` | 设置为 `daemon` 使用 nix-daemon |
| `NIX_PATH` | nixpkgs 搜索路径 (传统用法) |

### 调试 nix 配置

```bash
# 查看当前生效的所有配置
nix show-config

# 查看特定配置（注意：access-tokens 出于安全考虑会显示为空）
nix show-config | grep substituters

# 测试配置是否生效
NIX_CONFIG="extra-access-tokens = github.com=token" nix flake metadata github:user/repo

# 使用自定义配置目录测试
mkdir -p /tmp/nixtest
echo 'max-jobs = 8' > /tmp/nixtest/nix.conf
NIX_CONF_DIR=/tmp/nixtest nix show-config | grep max-jobs
```

### 参考文档

- [nix.conf 官方手册](https://nix.dev/manual/nix/2.24/command-ref/conf-file.html)
- [环境变量参考](https://nix.dev/manual/nix/2.24/command-ref/env-common)
- [GitHub Issue #6536 - access-tokens 无法使用 !include](https://github.com/NixOS/nix/issues/6536)

---

## 调试技巧总结

### 1. 查看 systemd 服务状态
```bash
# 系统服务
systemctl status <service>
systemctl list-units --failed

# 用户服务
systemctl --user status <service>
systemctl --user list-units --failed
```

### 2. 查看日志
```bash
# 系统日志
journalctl -b -u <service>
journalctl -b | grep -i <keyword>

# 用户服务日志
journalctl --user -b -u <service>
```

### 3. 检查服务依赖
```bash
systemctl --user list-dependencies <target>
systemctl show <service> -p After,Wants,Requires
```

### 4. 检查环境变量
```bash
# 当前 shell
echo $VARIABLE_NAME

# systemd 用户环境
systemctl --user show-environment | grep VARIABLE
```

### 5. 检查文件权限和内容
```bash
ls -la /path/to/file
cat /path/to/file | od -c  # 查看隐藏字符
```

### 6. 搜索配置
```bash
grep -rn "keyword" /home/user/nixos-config --include="*.nix"
```

### 7. Git 差异分析
```bash
git log --oneline -10
git show <commit> --stat
git diff <old-commit>..<new-commit> -- <file>
```

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `modules/system/default.nix` | 添加 `inputs` 到 extraSpecialArgs |
| `home/linux/gui/hyprland/hyprland.nix` | 使用 flake 的 hyprland 包 |
| `home/linux/gui/hyprland/xdg.nix` | 移除重复的 portal 包 |
| `home/linux/gui/hyprland/conf/exec.conf` | 添加环境变量导入和服务重启 |
| `home/linux/gui/hyprland/conf/fcitx5.conf` | 修复 windowrule 语法 |
| `home/linux/gui/base/theme.nix` | 启用 catppuccin cursors |
| `modules/system/sops.nix` | 使用环境变量传递 access-tokens |
| `home/shell/zsh.nix` | 移除 GTK_IM_MODULE 和 QT_IM_MODULE |
| `home/fcitx5/default.nix` | 添加 GTK 配置文件用于 XWayland 应用 |

---

## 核心教训

1. **版本一致性**: 系统级和 home-manager 级使用的包版本必须一致
2. **systemd 时序问题**: wayland 服务需要等待 compositor 设置环境变量后才能启动
3. **nix 配置限制**: `access-tokens` 无法通过 `!include` 从文件读取，需要使用环境变量
4. **catppuccin 模块**: 全局 enable 不会自动启用所有子模块，cursors 需要单独启用
5. **Wayland 输入法**: 不要设置 `GTK_IM_MODULE` 环境变量，让应用使用 text-input-v3 协议

---

## 问题八：fcitx5 输入法候选框位置错误与全屏消失

### 症状
1. 输入法候选框位置偏上或偏下，不在光标附近
2. 在 VSCode 等应用全屏时，候选框完全消失
3. XWayland 应用中候选框可能出现在屏幕左上角 (0,0)

### 诊断过程

#### 1. 检查当前环境变量
```bash
env | grep -E "IM_MODULE|XMODIFIERS"
```

**问题发现**:
```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

#### 2. 理解 Wayland 下输入法的工作原理

在 Wayland 下，输入法有两种工作模式：

**模式 A: IM 模块模式 (GTK_IM_MODULE/QT_IM_MODULE)**
- fcitx5 的 IM 模块在应用进程内部渲染候选框
- 候选框作为应用窗口的子窗口
- 问题：Wayland 没有全局坐标系统，候选框位置计算可能出错
- 问题：全屏时子窗口可能被裁剪或无法显示

**模式 B: text-input 协议模式 (推荐)**
- 应用通过 Wayland 的 text-input-v3 协议与合成器通信
- fcitx5 的 waylandFrontend 接收输入事件
- fcitx5 使用 layer-shell 协议在合成器层面显示候选框
- 候选框独立于应用窗口，位置由合成器控制

### 根本原因

设置 `GTK_IM_MODULE=fcitx` 会强制 GTK 应用使用模式 A，而不是更适合 Wayland 的模式 B。

根据 [fcitx5 官方文档](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland/zh-cn)：
> "Wayland 缺乏全局坐标系统，原生 Wayland 客户端无法精确定位输入法弹窗"

### 解决方案

#### 1. 移除全局 IM 环境变量

修改 `home/shell/zsh.nix`，移除 `GTK_IM_MODULE` 和 `QT_IM_MODULE`：

```nix
sessionVariables = {
  # 输入法设置
  # 在 Wayland 下，不应该设置 GTK_IM_MODULE 和 QT_IM_MODULE
  # GTK3/4 和 Qt 6.7+ 会自动使用 text-input-v3 协议
  # 设置这些变量会导致候选框位置错误和全屏时消失的问题
  #
  # XMODIFIERS 仍然需要，用于 XWayland 应用的 XIM 协议
  XMODIFIERS = "@im=fcitx";
};
```

#### 2. 为 XWayland 应用配置 GTK IM 模块

通过 GTK 配置文件（而非环境变量）为 X11 应用设置 IM 模块。修改 `home/fcitx5/default.nix`：

```nix
xdg.configFile = {
  # ... fcitx5/profile 配置 ...

  # GTK 输入法配置 - 只对 X11/XWayland 应用生效
  "gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-im-module=fcitx
    '';
  };
  "gtk-4.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-im-module=fcitx
    '';
  };
};

# GTK2 配置
home.file.".gtkrc-2.0".text = ''
  gtk-im-module="fcitx"
'';
```

#### 3. 确保 Electron 应用使用正确参数

对于 VSCode 等 Electron 应用，需要启用 Wayland IME：

```nix
programs.vscode = {
  enable = true;
  package = pkgs.vscode.override {
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--ozone-platform=wayland"
      "--gtk-version=4"
      "--enable-wayland-ime"  # 关键参数
    ];
  };
};
```

### 技术细节

#### Wayland text-input 协议版本

| 协议 | 支持的合成器 | 说明 |
|------|-------------|------|
| text-input-v1 | Weston, 部分 Chromium | 较旧，功能有限 |
| text-input-v2 | KWin (KDE) | 仅 KDE 使用 |
| text-input-v3 | Hyprland, Sway, GNOME | 现代标准，推荐使用 |

#### 各框架的 IM 支持

| 框架 | Wayland 原生支持 | 环境变量需求 |
|------|-----------------|-------------|
| GTK3/4 | text-input-v3 | 不需要设置 GTK_IM_MODULE |
| Qt 6.7+ | text-input-v3 | 不需要设置 QT_IM_MODULE |
| Qt < 6.7 | text-input-v2 (KWin) | 需要 QT_IM_MODULE=fcitx |
| Electron | --enable-wayland-ime | 需要命令行参数 |

#### 为什么 GTK 配置文件方式更好？

设置 `GTK_IM_MODULE` 环境变量会影响**所有** GTK 应用，包括 Wayland 原生应用。

而在 `gtk-3.0/settings.ini` 中设置 `gtk-im-module=fcitx`：
- 只影响通过 X11/XWayland 运行的应用
- Wayland 原生 GTK 应用会忽略这个配置，使用 text-input-v3

### 调试命令

```bash
# 查看当前 IM 环境变量
env | grep -E "IM_MODULE|XMODIFIERS"

# 查看 fcitx5 进程
pgrep -a fcitx

# 查看 VSCode 启动参数（确认 wayland-ime 已启用）
pgrep -a code | grep wayland

# 测试 - 重启 fcitx5
pkill fcitx5 -9; sleep 1; fcitx5 -d --replace

# 查看 GTK 配置
cat ~/.config/gtk-3.0/settings.ini
cat ~/.config/gtk-4.0/settings.ini
```

### 尝试的解决方案（未完全解决）

#### 尝试 1：移除 GTK_IM_MODULE 和 QT_IM_MODULE 环境变量

**理论依据**：根据 fcitx5 官方文档，在 Wayland 下不应该设置这些环境变量，让应用使用 text-input-v3 协议。

**修改文件**：`home/shell/zsh.nix`
```nix
sessionVariables = {
  # 移除 GTK_IM_MODULE 和 QT_IM_MODULE
  # 在 Wayland 下，GTK3/4 和 Qt 6.7+ 会自动使用 text-input-v3 协议
  XMODIFIERS = "@im=fcitx";  # 只保留这个，用于 XWayland
};
```

**结果**：环境变量已正确移除，但候选框位置问题仍然存在。

#### 尝试 2：通过 GTK 配置文件设置 IM 模块

**理论依据**：不用环境变量，改用 GTK 配置文件，只影响 X11/XWayland 应用。

**修改文件**：`home/fcitx5/default.nix`
```nix
xdg.configFile = {
  "gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-im-module=fcitx
    '';
  };
  "gtk-4.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-im-module=fcitx
    '';
  };
};

home.file.".gtkrc-2.0".text = ''
  gtk-im-module="fcitx"
'';
```

**结果**：配置正确生成，但问题仍然存在。

#### 尝试 3：调整 fcitx5 ClassicUI 配置

**理论依据**：多显示器环境下 DPI 计算可能导致位置偏移。

**修改文件**：`home/fcitx5/default.nix`
```nix
"fcitx5/conf/classicui.conf" = {
  text = ''
    Theme=catppuccin-mocha-pink
    # 禁用 Per Screen DPI，避免多显示器位置计算错误
    PerScreenDPI=False
    # 强制 Wayland DPI
    ForceWaylandDPI=96
    # 启用分数缩放支持
    EnableFractionalScale=True
  '';
  force = true;
};
```

**结果**：配置已应用，但问题仍然存在。

### 问题根本原因分析

经过深入研究，发现这是一个 **Hyprland + fcitx5 的已知兼容性问题**：

#### 1. 候选框位置偏移

**原因**：
- Wayland 没有全局坐标系统
- text-input-v3 协议传递的光标位置可能不准确
- 多显示器环境下问题更明显

**相关 Issue**：
- [Hyprland #3009 - Fcitx5 candidate box position incorrect](https://github.com/hyprwm/Hyprland/issues/3009)
- [Hyprland #6534 - Fcitx5 input box misaligned in xwayland](https://github.com/hyprwm/Hyprland/issues/6534)
- [fcitx5 #1135 - Candidate window position not right](https://github.com/fcitx/fcitx5/issues/1135)

#### 2. 全屏时候选框消失

**原因**：
- fcitx5 候选框被全屏窗口遮挡
- Wayland 层级（layer）优先级问题
- Hyprland 的 fullscreen 实现与 fcitx5 的 layer-shell 不兼容

**相关 Issue**：
- [Hyprland #8773 - Fcitx5 Input candidate bar disappear in full screen mode](https://github.com/hyprwm/Hyprland/issues/8773) - 状态：**Closed (Not Planned)**
- [fcitx5 #821 - 全屏模式下候选框消失](https://github.com/fcitx/fcitx5/issues/821)

### 技术背景

#### Wayland 下输入法的两种工作模式

| 模式 | 原理 | 优点 | 缺点 |
|------|------|------|------|
| **IM 模块模式** | fcitx5 的 GTK/Qt 模块在应用进程内渲染候选框 | 兼容性好 | 候选框作为子窗口，全屏时被裁剪 |
| **text-input 协议模式** | 应用通过 text-input-v3 与合成器通信，fcitx5 用 layer-shell 显示候选框 | 候选框独立于应用 | 位置依赖合成器实现，可能不准确 |

#### 当前环境状态

```bash
# 检查环境变量
$ env | grep -E "IM_MODULE|XMODIFIERS"
GLFW_IM_MODULE=ibus
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
# GTK_IM_MODULE 和 QT_IM_MODULE 已不存在 ✓

# 检查显示器配置
$ hyprctl monitors -j | jq -r '.[] | "\(.name) - \(.width)x\(.height) @ scale \(.scale)"'
DP-1 - 3840x2160 @ scale 1.00
DP-2 - 2560x1440 @ scale 1.00

# 检查应用是否为 Wayland 原生
$ hyprctl clients -j | jq -r '.[] | "\(.class) - xwayland: \(.xwayland)"'
code - xwayland: false  # 所有应用都是 Wayland 原生
```

### 当前状态

**问题未解决**，等待上游（Hyprland 或 fcitx5）修复。

### 可能的替代方案（未尝试）

1. **使用 XWayland 模式运行应用**
   ```bash
   GDK_BACKEND=x11 code  # 强制 VSCode 使用 XWayland
   ```

2. **使用 kimpanel 替代 classicui**
   - 需要 KDE 集成
   - 候选框由桌面环境管理

3. **等待 Hyprland 0.53+ 或 fcitx5 更新**

### 参考资料

- [fcitx5 Wayland 官方文档](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)
- [fcitx5 Wayland 中文文档](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland/zh-cn)
- [Hyprland fcitx5 候选框问题 #6534](https://github.com/hyprwm/Hyprland/issues/6534)
- [Hyprland fcitx5 位置问题 #3009](https://github.com/hyprwm/Hyprland/issues/3009)
- [Hyprland fcitx5 全屏消失 #8773](https://github.com/hyprwm/Hyprland/issues/8773)
- [fcitx5 全屏问题 #821](https://github.com/fcitx/fcitx5/issues/821)
- [fcitx5 候选框位置问题 #1135](https://github.com/fcitx/fcitx5/issues/1135)
- [ArchWiki Fcitx5](https://wiki.archlinux.org/title/Fcitx5)

---

## 问题九：Hyprland 启动后软件缓慢轮流打开，waybar 等待很久

### 症状
1. 登录 Hyprland 后，各个软件缓慢轮流打开
2. waybar 需要等待约 2 分钟才会出现
3. 系统日志显示 waybar 反复失败重启

### 诊断过程

#### 1. 分析 systemd 服务启动时间
```bash
systemd-analyze blame --user | head -20
```

#### 2. 查看 waybar 状态
```bash
systemctl --user status waybar.service
```

发现日志显示：
```
Error calling StartServiceByName for org.freedesktop.portal.Desktop: Timeout was reached
```

#### 3. 查看启动时序日志
```bash
journalctl --user -b | grep -E "graphical-session|WAYLAND_DISPLAY|waybar|portal"
```

**关键发现**：
```
17:04:22 - Reached target Fake graphical-session target
17:04:22 - waybar was skipped (ConditionEnvironment=WAYLAND_DISPLAY)
17:04:22 - hypridle was skipped (ConditionEnvironment=WAYLAND_DISPLAY)
17:04:23 - xdg-desktop-portal-gtk: cannot open display:
17:04:23 - portal-gtk Failed
17:04:25 - waybar 首次启动 (通过 exec.conf restart)
17:04:50 - waybar 失败: portal.Desktop Timeout (25秒)
17:04:51 - waybar 重试
17:05:16 - waybar 失败: portal.Desktop Timeout
... (反复5-6次)
17:06:22 - portal 超时失败，systemd 杀死并重启
17:06:23 - portal-gtk 终于成功启动
17:06:23 - portal 成功启动
17:06:23 - waybar 成功启动
```

### 根本原因

问题链条：

1. **ly 显示管理器** 启动 Hyprland
2. **nixos-fake-graphical-session.target** 被激活（因为 Hyprland 不在 systemd-aware 列表中）
3. 这触发了 **graphical-session.target**
4. **此时 WAYLAND_DISPLAY 还没设置**（Hyprland 还没完全启动）
5. 依赖 `ConditionEnvironment=WAYLAND_DISPLAY` 的服务被跳过（waybar, hypridle）
6. **xdg-desktop-portal-gtk** 被启动，但因为 `cannot open display:` 失败
7. **xdg-desktop-portal** 等待 portal-gtk，超时 90 秒后失败
8. exec.conf 中的 `systemctl --user restart waybar.service` 启动 waybar
9. waybar 尝试连接 portal，但 portal 还没准备好，等待超时（25秒）
10. waybar 因 `Restart=on-failure` 反复重试
11. 约 2 分钟后，portal 被 systemd 杀死并重启，这次有了正确的环境变量
12. portal-gtk 和 portal 成功启动
13. waybar 终于成功

### 解决方案

修改 `home/linux/gui/hyprland/conf/exec.conf`，确保 portal 服务在有正确环境变量后重启：

```bash
# 导入环境变量到 systemd user session
# 这一步必须在所有依赖 WAYLAND_DISPLAY 的服务之前执行
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

# 重启 portal 服务（它们可能因为缺少 DISPLAY 而失败）
# portal-gtk 必须先启动，因为 xdg-desktop-portal 依赖它
exec-once = systemctl --user restart xdg-desktop-portal-gtk.service xdg-desktop-portal-hyprland.service xdg-desktop-portal.service

# 等待 portal 完全启动后再启动 waybar（waybar 依赖 portal）
exec-once = sleep 1 && systemctl --user restart waybar.service hypridle.service
```

**关键改动**：
1. 添加 `xdg-desktop-portal-gtk.service` 和 `xdg-desktop-portal.service` 到重启列表
2. 分离 portal 重启和 waybar 重启，中间加 `sleep 1` 等待 portal 就绪
3. 使用 `&&` 确保顺序执行

### 技术背景

#### 什么是 xdg-desktop-portal？

`xdg-desktop-portal` 是 Freedesktop 标准的**沙盒应用通信桥梁**，让沙盒应用（Flatpak、Snap）和 Wayland 应用能够安全地访问系统功能。

**主要功能**：

| Portal 接口 | 功能 | 使用场景 |
|------------|------|---------|
| `FileChooser` | 文件选择对话框 | 应用请求打开/保存文件 |
| `Screenshot` | 截图功能 | 截图工具、应用内截图 |
| `ScreenCast` | 屏幕录制/共享 | Zoom、Teams、OBS 等 |
| `Notification` | 桌面通知 | 应用发送通知 |
| `OpenURI` | 打开 URL | 用默认浏览器打开链接 |
| `Settings` | 读取系统设置 | 获取主题、字体、颜色方案 |
| `Secret` | 密钥环访问 | 安全存储密码 |
| `Print` | 打印对话框 | 打印文档 |

**架构**：

```
应用程序 (VSCode, Firefox, Chrome, 等)
    ↓ D-Bus 请求: org.freedesktop.portal.Desktop
xdg-desktop-portal (主服务 - 路由器)
    ↓ 根据功能分发到不同后端
    ├── xdg-desktop-portal-hyprland (Hyprland 专用)
    │   ├── Screenshot (截图)
    │   ├── ScreenCast (屏幕共享)
    │   └── GlobalShortcuts (全局快捷键)
    │
    └── xdg-desktop-portal-gtk (GTK 后端)
        ├── FileChooser (文件选择器)
        ├── AppChooser (应用选择器)
        ├── Print (打印对话框)
        └── Settings (系统设置读取)
```

#### 为什么 Wayland 特别需要 portal？

**X11 时代**：任何应用都能：
- 随意截取任何窗口的内容
- 读取其他窗口的键盘输入
- 访问任意文件路径
- 模拟键盘/鼠标输入

**Wayland 设计**：应用被严格隔离
- 应用看不到其他应用的窗口
- 不能随意截屏
- 不能访问任意文件
- 必须通过 portal 请求权限

**具体例子**：

```
VSCode 想打开文件：
1. VSCode 调用 D-Bus: org.freedesktop.portal.FileChooser.OpenFile
2. xdg-desktop-portal 收到请求
3. portal 转发给 xdg-desktop-portal-gtk
4. GTK 文件选择器弹出（由系统控制，不是 VSCode）
5. 用户选择文件
6. portal 返回文件路径给 VSCode
7. VSCode 只能访问用户明确选择的文件

好处：
- VSCode 无法偷偷扫描你的整个文件系统
- 即使 VSCode 被攻击，攻击者也只能访问用户选择的文件
```

#### portal 配置文件

portal 通过 `/usr/share/xdg-desktop-portal/portals/` 和 `~/.config/xdg-desktop-portal/` 中的配置文件决定使用哪个后端：

```ini
# ~/.config/xdg-desktop-portal/hyprland-portals.conf
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.FileChooser=gtk
org.freedesktop.impl.portal.Settings=gtk
```

#### systemd 服务依赖关系

```
graphical-session.target
├── xdg-desktop-portal.service (需要 portal backends)
│   ├── xdg-desktop-portal-gtk.service (需要 DISPLAY)
│   └── xdg-desktop-portal-hyprland.service (需要 WAYLAND_DISPLAY)
├── waybar.service (需要 WAYLAND_DISPLAY + portal)
└── hypridle.service (需要 WAYLAND_DISPLAY)
```

#### 为什么 portal-gtk 需要 DISPLAY？

portal-gtk 是一个 GTK 应用，用于提供：
- 文件选择器 (File Chooser)
- 应用程序选择器 (App Chooser)
- 打印对话框 (Print Dialog)
- 截图预览

这些都需要 GUI，所以必须有 DISPLAY 环境变量。

#### ConditionEnvironment 的作用

```ini
[Unit]
ConditionEnvironment=WAYLAND_DISPLAY
```

这会让 systemd 在启动服务前检查环境变量是否存在。如果不存在，服务会被**跳过**而不是失败。但问题是 portal-gtk 没有这个条件，所以它会尝试启动并失败。

### 调试命令

```bash
# 查看用户服务启动时间
systemd-analyze blame --user | head -20

# 查看关键路径
systemd-analyze critical-chain --user waybar.service

# 查看 portal 日志
journalctl --user -b -u xdg-desktop-portal.service
journalctl --user -b -u xdg-desktop-portal-gtk.service

# 查看启动时序
journalctl --user -b | grep -E "portal|waybar|graphical-session"

# 手动重启所有相关服务
systemctl --user restart xdg-desktop-portal-gtk.service xdg-desktop-portal-hyprland.service xdg-desktop-portal.service waybar.service
```

### 参考资料

- [Hyprland Wiki - Systemd Integration](https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/#systemd-integration)
- [xdg-desktop-portal GitHub](https://github.com/flatpak/xdg-desktop-portal)
- [xdg-desktop-portal 官方文档](https://flatpak.github.io/xdg-desktop-portal/)
- [Freedesktop.org - Desktop Portal](https://www.freedesktop.org/wiki/Software/xdg-desktop-portal/)
- [ArchWiki - XDG Desktop Portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal)
- [Hyprland xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- [NixOS Discourse - Hyprland Portal Issues](https://discourse.nixos.org/)
