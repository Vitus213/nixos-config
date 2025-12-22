{ pkgs, config, ... }:
{
  # 从本地目录安装自定义字体（微软雅黑）
  home.file = {
    ".local/share/fonts/msyh.ttf".source = ../../fonts/msyh.ttf;
  };

  # 字体安装后需要重建字体缓存
  home.activation.refreshFonts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.fontconfig}/bin/fc-cache -fv
  '';
}
