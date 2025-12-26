{
  catppuccin,
  pkgs,
  lib,
  ...
}:
{
  # https://github.com/catppuccin/nix
  imports = [ catppuccin.homeModules.catppuccin ];

  catppuccin = {
    # The default `enable` value for all available programs.
    enable = true;
    # one of "latte", "frappe", "macchiato", "mocha"
    flavor = "mocha";
    # one of "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    accent = "pink";
    # 使用 catppuccin cursor
    cursors.enable = lib.mkForce true;
    delta.enable = true;
    # 禁用 bat 主题以避免与手动配置冲突
    # bat.enable = false;
    bat.enable = true;
  };

  # # 手动设置 pointerCursor，使用 catppuccin-cursors
  # home.pointerCursor = {
  #   name = "catppuccin-mocha-pink-cursors";
  #   package = pkgs.catppuccin-cursors.mochaPink;
  #   size = 24;
  #   gtk.enable = true;
  #   x11.enable = true;
  # };
}
