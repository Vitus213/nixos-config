{ config, inputs, ... }:
{
  imports = [
    ./code.nix
    ./monitoring.nix
    ./hardware.nix
    ./terminals.nix
    ./shell-tools.nix
    ./git.nix

  ];
}
