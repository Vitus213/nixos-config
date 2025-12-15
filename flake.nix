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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, vscode-server
    , rust-overlay, anyrun, catppuccin, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

    in {
      # ========== NixOS 主机配置 ==========
      # 使用: sudo nixos-rebuild switch (如果已链接到 /etc/nixos)
      # 或:   sudo nixos-rebuild switch --flake ~/.config/home-manager#Vitus5600

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
          ./overlays
          ./hosts/Vitus5600
          ./modules/system/packages.nix # Software packages
          ./modules/system/system.nix
          ./modules/system/nvidia.nix # Nvidia 驱动
          ./users/${username}/nixos.nix
          sops-nix.nixosModules.sops
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
          sops-nix.nixosModules.sops
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

      # ========== 非 NixOS 系统配置 (Ubuntu, WSL, Debian 等) ==========
      # 使用: home-manager switch --flake .#vitus@ubuntu
      # 或:   home-manager switch --flake .#vitus@wsl

      homeConfigurations = let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # 共享的核心模块 (CLI 环境)
        coreModules = [
          ./home/core.nix
          ./home/shell
          ./home/programs/shell-tools.nix
          ./home/programs/git.nix
        ];
      in {
        # Ubuntu / Debian / 通用 Linux (仅 CLI)
        "vitus@ubuntu" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs unstable;
            username = "vitus";
            hostname = "ubuntu";
          };
          modules = coreModules ++ [
            {
              home.username = "vitus";
              home.homeDirectory = "/home/vitus";
              home.stateVersion = "25.05";
              programs.home-manager.enable = true;

              # Nix 配置 (非 NixOS 系统需要)
              nix = {
                package = pkgs.nix;
                settings.experimental-features = [ "nix-command" "flakes" ];
              };

              # Git 配置
              programs.git = {
                enable = true;
                userName = "Vitus";
                userEmail = "zhzvitus@gmail.com";
                extraConfig.init.defaultBranch = "main";
              };

              # Bash 配置
              programs.bash = {
                enable = true;
                enableCompletion = true;
              };
            }
          ];
        };

        # WSL 专用配置
        "vitus@wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs unstable;
            username = "vitus";
            hostname = "wsl";
          };
          modules = coreModules ++ [
            {
              home.username = "vitus";
              home.homeDirectory = "/home/vitus";
              home.stateVersion = "25.05";
              programs.home-manager.enable = true;

              nix = {
                package = pkgs.nix;
                settings.experimental-features = [ "nix-command" "flakes" ];
              };

              programs.git = {
                enable = true;
                userName = "Vitus";
                userEmail = "zhzvitus@gmail.com";
                extraConfig.init.defaultBranch = "main";
              };

              programs.bash = {
                enable = true;
                enableCompletion = true;
              };

              # WSL 特定设置
              home.sessionVariables = {
                BROWSER = "wslview";
              };
            }
          ];
        };
      };
    };
}
