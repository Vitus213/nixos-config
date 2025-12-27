{
  config,
  nixpkgs,
  inputs,
  username,
  unstable,
  hostname,
  ...
}:
{
  imports = [
    ./packages.nix
    ./system.nix
    ./themes.nix
    ./sops.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ../../users/${username}/home.nix;
    extraSpecialArgs = inputs // {
      inherit unstable username hostname;
    };
    backupFileExtension = "backup";
  };

  services.vscode-server.enable = true;
}
