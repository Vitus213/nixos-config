{ config, nixpkgs, ... }:
{
  imports = [
    ./packages.nix
    ./system.nix
    ./themes.nix
    ./sops.nix
    
  ];
}
