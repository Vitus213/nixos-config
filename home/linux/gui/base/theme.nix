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
    bat.enable = true;
    kitty.enable = true;
  };
}
