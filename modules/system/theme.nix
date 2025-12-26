{
  config,
  nixpkgs,
  catppuccin,
  ...
}:
{
  import = [ catppuccin.nixosModules.catppuccin ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    # one of "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    accent = "pink";
  };
}
