{
  pkgs,
  config,
  username,
  ...
}:{
  # 在 home-manager 中，字体通过 home.packages 安装
  # 引用公共字体列表
  home.packages = import ../fonts-list.nix { inherit pkgs; };

  # fontconfig 在 home-manager 中的配置方式
  fonts.fontconfig.enable = true;
}