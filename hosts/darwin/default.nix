# Darwin (macOS) 主机配置
{
  pkgs,
  hostname,
  username,
  ...
}:

{
  # 网络配置
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # 用户配置
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.zsh;
  };
  system.primaryUser = username;

nix.settings = {
    trusted-users = [ "root" username ];
    # # 解决 Go 项目下载超时的核心配置
    # sandbox = false;
    # http_proxy = "http://127.0.0.1:7897"; # 请确认你的代理端口
    # https_proxy = "http://127.0.0.1:7897";
  };

  # 系统版本
  system.stateVersion = 6;

  # 系统默认设置
  system.defaults = {
    menuExtraClock.Show24Hour = true;
  };

  # TouchID 支持 sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # 只启用 Home Manager 的 sops-nix，关闭系统级 sops
  modules.systemsecrets.enable = true;
}
