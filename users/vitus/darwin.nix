{ pkgs, username, inputs, ... }:
{
  imports=[
    ./../../home/shell
  ];

  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  programs.home-manager.enable = true;
}
