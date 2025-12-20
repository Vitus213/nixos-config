# Darwin Nix 核心配置
{ pkgs, lib, ... }:

{
  # 允许 unfree 软件包
  nixpkgs.config.allowUnfree = true;

  nix = {
    # Determinate uses its own daemon to manage the Nix installation that
    # conflicts with nix-darwin's native Nix management.
    # Set this to false if you're using Determinate Nix.
    enable = true;

    package = pkgs.nix;

    settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # substituers that will be considered before the official ones(https://cache.nixos.org)
      substituters = [
        "https://nix-community.cachix.org"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      builders-use-substitutes = true;

      # Disable auto-optimise-store because of this issue:
      #   https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = false;
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
