# Darwin Home Manager 配置
{
  config,
  pkgs,
  lib,
  username,
  home-manager,
  ...
}:

{
  # Import home-manager darwin module
  imports = [
    home-manager.darwinModules.home-manager
  ];  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs= {inherit inputs;};
    users.${username} = import ../users/${username}/common.nix;
    sharedModules  =[
      ./shell
    ]  
  };
}
