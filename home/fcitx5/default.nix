{ config, pkgs, ... }: # 模块的入口，config 是当前配置，pkgs 是 nixpkgs 库

# let
#   # 1. 定义你的自定义 rime-data derivation
#   myRimeDataVitus = pkgs.stdenv.mkDerivation {
#     pname = "rime-data-vitus"; # 包的名称，用于显示和标识
#     version = "1.0";          # 包的版本，也是标识
#     src = pkgs.lib.cleanSource ./rime-data-vitus; # 源文件！

#     # 定义构建步骤
#     installPhase = ''
#       mkdir -p $out/share/rime-data
#       cp -r $src/. $out/share/rime-data/
#     '';
#   };

#   # 2. 覆写 fcitx5-rime 包以使用你的自定义数据
#   fcitx5RimeCustom = pkgs.fcitx5-rime.overrideAttrs (oldAttrs: {
#     # 覆写 fcitx5-rime 包的 rimeDataPkgs 属性
#     rimeDataPkgs = [ myRimeDataVitus ];
#   });

# in
# {
#   i18n.inputMethod = {
#     enable = true;
#     type = "fcitx5";
#     fcitx5.addons = with pkgs; [
#       fcitx5RimeCustom # <-- 在这里使用你修改后的 fcitx5-rime 包
#       fcitx5
#       fcitx5-gtk
#       fcitx5-configtool
#     ];
#   };
# }
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime # <-- 在这里使用你修改后的 fcitx5-rime 包
        fcitx5
        fcitx5-gtk
        fcitx5-configtool
      ];
    };
  };
}
