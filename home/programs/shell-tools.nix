{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lsd
    zoxide
    which
    tree
    # 密钥管理
    sops
    age
    # 网络工具
    nettools
  ];
  programs = {
    neovim = {
      enable = true;
      defaultEditor = false;
    };
  };
}
