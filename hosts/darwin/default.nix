# Darwin (macOS) 主机配置
{ pkgs, hostname, username, ... }:

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

  nix.settings.trusted-users = [ username ];

  # 系统版本
  system.stateVersion = 6;

  # 系统默认设置
  system.defaults = {
    menuExtraClock.Show24Hour = true;
  };

  # TouchID 支持 sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
