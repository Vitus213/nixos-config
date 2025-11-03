{ lib, pkgs, catppuccin-bat, ... }: {
  home.packages = with pkgs; [
    uv
    python314
  ];

}