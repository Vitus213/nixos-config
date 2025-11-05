{
  description = "Vitus's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # import plugin
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # anyrun - a wayland launcher
    anyrun = {
      url = "github:/anyrun-org/anyrun/v25.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, vscode-server
    , rust-overlay, anyrun, catppuccin, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

    in {
      nixosConfigurations.Vitus5600 = let
        username = "vitus";
        hostname = "Vitus5600";
        specialArgs = {
          inherit system;
          inherit inputs;
          inherit unstable;
          inherit username;
          inherit hostname;
        };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/Vitus5600
          ./modules/system/packages.nix # Software packages
          ./modules/system/system.nix
          ./modules/system/nvidia.nix # Nvidia 驱动
          ./users/${username}/nixos.nix
          #将home-manager模块添加到NixOS配置中
          #这样在nixos-rebuild switch 时，home-manager的配置也会被应用
          home-manager.nixosModules.home-manager
          ({ username, unstable, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./users/${username}/home.nix;
              extraSpecialArgs = inputs // specialArgs;
              backupFileExtension = "backup";
            };
          })
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: { services.vscode-server.enable = true; })
        ];
      };

      nixosConfigurations.Vitus8500 = let
        username = "vitus";
        hostname = "Vitus8500";
        specialArgs = {
          inherit system;
          inherit inputs;
          inherit unstable;
          inherit username;
          inherit hostname;
        };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/Vitus8500
          ./modules/system/packages.nix # Software packages
          ./modules/system/system.nix
          ./users/${username}/nixos.nix
          #将home-manager模块添加到NixOS配置中
          #这样在nixos-rebuild switch 时，home-manager的配置也会被应用
          home-manager.nixosModules.home-manager
          ({ username, unstable, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./users/${username}/home.nix;
              extraSpecialArgs = inputs // specialArgs;
              backupFileExtension = "backup";
            };
          })
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: { services.vscode-server.enable = true; })
        ];
      };
    };
}
