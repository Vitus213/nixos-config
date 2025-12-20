{ pkgs, ... }:
{
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;
    userName = "Vitus213";
    userEmail = "zhzvitus@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "etc/nixos";
    };
  };
}
