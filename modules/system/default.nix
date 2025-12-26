{ config, nixpkgs, ... }:
{
  imports = [
    ./packages.nix
    ./system.nix
    ./themes.nix
    ./sop.nix
    home-manager.nixosModules.home-manager
    (
      { username, unstable, ... }:
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import ../../users/${username}/home.nix;
          extraSpecialArgs = inputs // specialArgs;
          backupFileExtension = "backup";
        };
      }
    )
    vscode-server.nixosModules.default
    (
      { config, pkgs, ... }:
      {
        services.vscode-server.enable = true;
      }
    )
  ];
}
