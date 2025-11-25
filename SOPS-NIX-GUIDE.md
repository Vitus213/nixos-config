# 🔐 sops-nix 完整配置指南

## 📖 目录
- [什么是 sops-nix](#什么是-sops-nix)
- [安装与配置](#安装与配置)
- [基础使用](#基础使用)
- [高级用法](#高级用法)
- [团队协作](#团队协作)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

## 什么是 sops-nix

sops-nix 是一个用于 NixOS 的密钥管理工具，它：
- 🔒 使用 GPG/Age 加密密钥文件
- 🚀 在系统启动时自动解密
- 👥 支持多用户/多密钥管理
- 📁 密钥文件可以安全地提交到 Git

## 安装与配置

### 1. 添加 flake 依赖

在 `flake.nix` 的 `inputs` 中添加：

```nix
sops-nix = {
  url = "github:Mic92/sops-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

在 `outputs` 参数中添加 `sops-nix`：

```nix
outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
```

在系统模块中添加：

```nix
modules = [
  # ... 其他模块
  sops-nix.nixosModules.sops
];
```

### 2. 生成 GPG 密钥

```bash
# 生成新的 GPG 密钥对
nix-shell -p gnupg --run "gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Your Name
Name-Email: your.email@example.com
Expire-Date: 2y
%no-protection
%commit
EOF"

# 查看生成的密钥
nix-shell -p gnupg --run "gpg --list-secret-keys --keyid-format=long"
```

记下输出中的密钥指纹（长串字符），例如：`F34CAAD44D2A409BC0FEAF03F09D691B034268B8`

### 3. 创建 .sops.yaml 配置文件

在项目根目录创建 `.sops.yaml`：

```yaml
keys:
  - &your-name YOUR_GPG_FINGERPRINT_HERE

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - pgp:
          - *your-name
```

### 4. 安装必要的系统包

在 `modules/system/system.nix` 中添加：

```nix
environment.systemPackages = with pkgs; [
  gnupg
  sops
];
```

## 基础使用

### 1. 创建加密的密钥文件

```bash
# 创建明文密钥文件
cat > secrets/secrets.yaml <<EOF
github_token: your_github_token_here
database_password: your_db_password
api_key: your_api_key
EOF

# 加密文件
nix-shell -p sops --run "sops --encrypt --in-place secrets/secrets.yaml"
```

### 2. 在 NixOS 配置中使用密钥

在任何 `.nix` 配置文件中：

```nix
{ config, ... }: {
  # 配置 sops
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # 定义要使用的密钥
  sops.secrets.github_token = {
    owner = "your-username";
    mode = "0400";  # 文件权限
  };

  sops.secrets.database_password = {
    owner = "postgres";
    group = "postgres";
  };

  # 在配置中使用密钥
  nix.settings.access-tokens = 
    "github.com=$(cat ${config.sops.secrets.github_token.path})";

  services.postgresql.authentication = ''
    host mydb myuser 127.0.0.1/32 md5
  '';
  # 密码将在运行时从 ${config.sops.secrets.database_password.path} 读取
}
```

### 3. 编辑加密文件

```bash
# 编辑现有加密文件
nix-shell -p sops --run "sops secrets/secrets.yaml"

# 这会临时解密文件供编辑，保存时自动重新加密
```

## 高级用法

### 多个密钥文件

```nix
# 为不同服务使用不同的密钥文件
sops.secrets = {
  # 从默认文件读取
  github_token = {};
  
  # 从特定文件读取
  database_credentials = {
    sopsFile = ../../secrets/database.yaml;
    owner = "postgres";
  };
  
  # 从二进制文件读取
  ssl_cert = {
    sopsFile = ../../secrets/cert.pem;
    format = "binary";
    owner = "nginx";
  };
};
```

### 条件使用密钥

```nix
# 只在特定条件下启用密钥
sops.secrets.production_api_key = lib.mkIf config.services.myapp.production {
  owner = "myapp";
};
```

### 密钥模板

```nix
# 使用密钥生成配置文件
sops.templates."myapp.conf".content = ''
  api_key=${config.sops.secrets.api_key.path}
  db_password=${config.sops.secrets.db_password.path}
  debug=false
'';

sops.templates."myapp.conf".owner = "myapp";

# 在服务中使用模板
systemd.services.myapp = {
  serviceConfig.ExecStart = "${pkgs.myapp}/bin/myapp --config ${config.sops.templates."myapp.conf".path}";
};
```

## 团队协作

### 添加团队成员

1. 获取团队成员的 GPG 公钥：

```bash
# 团队成员导出公钥
gpg --armor --export their.email@example.com > their-public-key.asc

# 你导入公钥
gpg --import their-public-key.asc
```

2. 更新 `.sops.yaml`：

```yaml
keys:
  - &you YOUR_GPG_FINGERPRINT
  - &teammate TEAMMATE_GPG_FINGERPRINT

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - pgp:
          - *you
          - *teammate
```

3. 重新加密所有密钥文件：

```bash
# 更新密钥文件以包含新成员
nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"
```

### 密钥轮换

```bash
# 1. 生成新的 GPG 密钥
# 2. 更新 .sops.yaml
# 3. 重新加密所有文件
find secrets/ -name "*.yaml" -exec sops updatekeys {} \;
```

## 故障排除

### 常见错误

#### 1. "key not available in keyring"

```bash
# 检查 GPG 密钥是否可用
gpg --list-secret-keys

# 确保在正确的环境中运行
nix-shell -p gnupg sops --run "sops secrets/secrets.yaml"
```

#### 2. 权限问题

```bash
# 检查密钥文件权限
ls -la /run/secrets/

# 确保用户有正确的所有权
sudo chown your-user:your-group /run/secrets/your-secret
```

#### 3. 构建失败

```bash
# 检查 sops 配置
nix-shell -p sops --run "sops --version"

# 验证密钥文件格式
nix-shell -p sops --run "sops --decrypt secrets/secrets.yaml"
```

### 调试技巧

```bash
# 查看所有可用的密钥
sudo ls -la /run/secrets/

# 测试密钥解密
sudo cat /run/secrets/your-secret

# 查看 systemd 日志
journalctl -u sops-nix
```

## 最佳实践

### 🔒 安全建议

1. **备份 GPG 密钥**：
   ```bash
   gpg --export-secret-keys YOUR_KEY_ID > ~/gpg-backup.key
   # 安全存储这个文件！
   ```

2. **设置合适的过期时间**：
   - GPG 密钥建议 1-2 年过期
   - 定期轮换密钥

3. **最小权限原则**：
   ```nix
   sops.secrets.sensitive_key = {
     owner = "specific-user";
     mode = "0400";  # 只有所有者可读
   };
   ```

### 📁 文件组织

```
nixos-config/
├── .sops.yaml           # sops 配置
├── secrets/
│   ├── secrets.yaml     # 通用密钥
│   ├── database.yaml    # 数据库相关
│   ├── ssl/             # SSL 证书
│   └── api-keys.yaml    # API 密钥
└── modules/
    └── secrets.nix      # 密钥配置模块
```

### 🚀 开发工作流

1. **开发环境**：
   ```bash
   # 使用示例密钥用于开发
   cp secrets/secrets.example.yaml secrets/secrets.yaml
   # 不要提交真实密钥到开发分支
   ```

2. **CI/CD 集成**：
   ```yaml
   # GitHub Actions 示例
   - name: Setup sops
     run: |
       nix-shell -p sops gnupg --run "echo $GPG_PRIVATE_KEY | gpg --import"
       nix-shell -p sops --run "sops --decrypt secrets/secrets.yaml"
   ```

### 🔄 维护

定期任务：
- [ ] 检查 GPG 密钥过期时间
- [ ] 更新 sops-nix 到最新版本
- [ ] 审核密钥访问权限
- [ ] 备份 GPG 密钥环

## 🆘 获取帮助

- [sops-nix GitHub](https://github.com/Mic92/sops-nix)
- [sops 官方文档](https://github.com/mozilla/sops)
- [NixOS Wiki: sops-nix](https://nixos.wiki/wiki/Sops-nix)

---

**⚠️ 重要提醒**: 
- 永远不要提交明文密钥到版本控制
- 定期备份和轮换密钥
- 遵循最小权限原则
- 监控密钥访问日志