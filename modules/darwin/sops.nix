# Darwin SOPS 配置
{ config, pkgs, username, ... }:

{
  # 安装 sops 和 age
  environment.systemPackages = with pkgs; [ sops age ssh-to-age ];

  # SOPS 配置
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    # 使用 age 密钥
    age = {
      # 密钥文件路径 (需要在 Mac 上手动创建)
      keyFile = "/Users/${username}/.config/sops/age/keys.txt";
      # 从 SSH 密钥生成 age 密钥
      sshKeyPaths = [ "/Users/${username}/.ssh/id_ed25519" ];
      generateKey = false;
    };

    # 定义需要解密的 secrets
    # 示例:
    # secrets = {
    #   "example_key" = {
    #     owner = username;
    #   };
    # };
  };
}
