{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lsd
    zoxide
    which
    tree
  ];
  programs={
        neovim = {
      enable = true;
      defaultEditor = false;
    };
  }
}
