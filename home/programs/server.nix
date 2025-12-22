{
  pkgs,
  config,
  username,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./tools.nix
    ./monitoring.nix
    ../shell
    ./shell-tools.nix
    ./fonts.nix
    ./custom-fonts.nix
    ./code.nix
  ];

}
