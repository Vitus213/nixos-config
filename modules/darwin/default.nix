# Darwin 模块入口
# 包含所有 Darwin (macOS) 相关的模块
{ ... }:

{
  imports = [ ./nix-core.nix ./system.nix ./apps.nix ];
}
