# ./overlays/default.nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.overlays = [
    # overlayer1 - 参数名用 self 与 super，表达继承关系
    (self: super: {
      microsoft-edge = super.microsoft-edge.override {
        commandLineArgs = "--proxy-server='https=127.0.0.1:7897;http=127.0.0.1:7897'";
      };
    })
  ];
}
