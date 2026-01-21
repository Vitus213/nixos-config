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

    # 启用 catppuccin 鼠标主题
    cursors = {
      enable = true;
      accent = "pink";
    };

    # 禁用 mpv 主题（需要下载 catppuccin-mpv）
    mpv.enable = false;
  };
}
