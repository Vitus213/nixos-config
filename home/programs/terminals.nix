{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kitty
    wezterm

  ];
  programs = {
    tmux.enable = true;
  };
}
