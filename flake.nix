{
  description = "Vitus's NixOS and nix-darwin configuration";
  inputs = {
    # ========== 通用 inputs ==========
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ========== NixOS 专用 inputs ==========
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    anyrun = {
      url = "github:/anyrun-org/anyrun/v25.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ========== Darwin 专用 inputs ==========
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      home-manager,
      nixpkgs-2511,
      vscode-server,
      fenix,
      anyrun,
      catppuccin,
      sops-nix,
      nix-darwin,
      ...
    }@inputs:
    let
      # ========== Linux 系统变量 ==========
      linuxSystem = "x86_64-linux";
      stable = import nixpkgs-2511 {
        system = linuxSystem;
        config.allowUnfree = true;
      };
      pkgs = import nixpkgs {
        system = linuxSystem;
        overlays = [ fenix.overlays.default ];
        config.allowUnfree = true;
      };
      # ========== Darwin 系统变量 ==========
      darwinSystem = "aarch64-darwin";
      unstableDarwin = import nixpkgs-darwin {
        system = darwinSystem;
        config.allowUnfree = true;
      };

    in
    {
      # ========== NixOS 主机配置 ==========
      # 使用: sudo nixos-rebuild switch --flake .#Vitus5600

      nixosConfigurations.Vitus5600 =
        let
          username = "vitus";
          hostname = "Vitus5600";
          specialArgs = {
            system = linuxSystem;
            inherit inputs;
            inherit stable;
            inherit username;
            inherit hostname;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./overlays
            ./hosts/Vitus5600
            ./modules/system
            ./modules/system/nvidia.nix
            ./users/${username}/nixos.nix
          ];
        };

      nixosConfigurations.Vitus8500 =
        let
          username = "vitus";
          hostname = "Vitus8500";
          specialArgs = {
            system = linuxSystem;
            inherit inputs;
            inherit stable;
            inherit username;
            inherit hostname;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.pkgs=pkgs; }
            ./hosts/Vitus8500
            ./modules/system
            ./users/${username}/nixos.nix
          ];
        };

      # ========== Darwin (macOS) 主机配置 ==========
      # 使用: darwin-rebuild switch --flake .#VitusMac

      darwinConfigurations.VitusMac =
        let
          username = "vitus";
          hostname = "VitusMac";
          specialArgs = inputs // {
            inherit inputs username hostname;
            unstable = unstableDarwin;
          };
        in
        nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          inherit specialArgs;
          modules = [
            ./hosts/darwin
            ./modules/darwin
            { nixpkgs.overlays = [ fenix.overlays.default ]; }
            home-manager.darwinModules.home-manager
            (
              { username, inputs, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.${username} = import ./users/${username}/darwin.nix;
                  extraSpecialArgs = { inherit inputs username; };
                };
              }
            )
            sops-nix.darwinModules.sops
          ];
        };

      # ========== 非 NixOS 系统配置 (Ubuntu, WSL, Debian 等) ==========
      # 使用: home-manager switch --flake .#vitus@ubuntu
      # 或:   home-manager switch --flake .#vitus@wsl

      homeConfigurations =
        let
          pkgs = import nixpkgs {
            system = linuxSystem;
            config.allowUnfree = true;
            overlays = [ fenix.overlays.default ];
          };

          # 共享的核心模块 (CLI 环境)
          coreModules = [
            ./home/core.nix
            ./home/programs/server.nix
          ];
        in
        {
          # Ubuntu / Debian / 通用 Linux (仅 CLI)
          "vitus@ubuntu" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs stable;
              username = "vitus";
              hostname = "ubuntu";
            };
            modules = coreModules ++ [
              {
                home.username = "vitus";
                home.homeDirectory = "/home/vitus";
                home.stateVersion = "25.11";
                programs.home-manager.enable = true;

                nix = {
                  package = pkgs.nix;
                  settings.experimental-features = [
                    "nix-command"
                    "flakes"
                  ];
                };

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
              inherit inputs stable;
              username = "vitus";
              hostname = "wsl";
            };
            modules = coreModules ++ [
              {
                home.username = "vitus";
                home.homeDirectory = "/home/vitus";
                home.stateVersion = "25.11";
                programs.home-manager.enable = true;

                nix = {
                  package = pkgs.nix;
                  settings.experimental-features = [
                    "nix-command"
                    "flakes"
                  ];
                };
                programs.bash = {
                  enable = true;
                  enableCompletion = true;
                };

                home.sessionVariables = {
                  BROWSER = "wslview";
                };
              }
            ];
          };
        };

      # ========== 格式化工具 ==========
      formatter.${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt-rfc-style;
      formatter.${darwinSystem} = nixpkgs-darwin.legacyPackages.${darwinSystem}.nixfmt-rfc-style;
    };
}
