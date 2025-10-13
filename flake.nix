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
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # import plugin
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, vscode-server
    , rust-overlay, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
    in {
      nixosConfigurations.Vitus5600 = nixpkgs.lib.nixosSystem {
        # 将 let 块中的 system 变量传递给 nixosSystem
        inherit system;
        #传递给所有nixos模块的额外参数
        specialArgs = {
          inherit inputs;
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/Vitus5600/configuration.nix
          #配置pkgs
          {
            nixpkgs = {
              overlays = overlays;
              config = { allowUnfree = true; };
            };
          }
          #将home-manager模块添加到NixOS配置中
          #这样在nixos-rebuild switch 时，home-manager的配置也会被应用
          home-manager.nixosModules.home-manager
          ({ unstable, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.vitus = import ./hosts/Vitus5600/home.nix;
              extraSpecialArgs = { inherit unstable; };
              backupFileExtension = "backup";
            };
          })

          vscode-server.nixosModules.default
          #启动tailscale
          ({ pkgs, ... }: {
            services.tailscale.enable = true;
            environment.systemPackages = with pkgs; [ tailscale ];
          })
          #启动蓝牙
          ({ pkgs, ... }: {
            hardware.bluetooth.enable = true;
            hardware.bluetooth.powerOnBoot = true;
          })
        ];
      };
      nixosConfigurations.Vitus8500 = nixpkgs.lib.nixosSystem {
        # 将 let 块中的 system 变量传递给 nixosSystem
        inherit system;
        #传递给所有nixos模块的额外参数
        specialArgs = {
          inherit inputs;
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/Vitus8500/configuration.nix
          #配置pkgs
          {
            nixpkgs = {
              overlays = overlays;
              config = { allowUnfree = true; };
            };
          }
          #将home-manager模块添加到NixOS配置中
          #这样在nixos-rebuild switch 时，home-manager的配置也会被应用
          home-manager.nixosModules.home-manager
          ({ unstable, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.vitus = import ./hosts/Vitus8500/home.nix;
              extraSpecialArgs = { inherit unstable; };
              backupFileExtension = "backup";
            };
          })

          vscode-server.nixosModules.default
          #启动tailscale
          ({ pkgs, ... }: {
            services.tailscale.enable = true;
            environment.systemPackages = with pkgs; [ tailscale ];
          })
          #启动蓝牙
          ({ pkgs, ... }: {
            hardware.bluetooth.enable = true;
            hardware.bluetooth.powerOnBoot = true;
          })
        ];
      };
    };

}
