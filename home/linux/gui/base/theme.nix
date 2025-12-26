{ catppuccin, pkgs, ... }:
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
    delta = {
      enable = true;
    };
  };

  # 鼠标主题 - Bibata 简洁小箭头
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
