{
  pkgs,
  lib,
  username,
  config,
  ...
}:
{
  imports = [ ./sops.nix ];
  modules.systemsecrets.enable = true;

  # ========== 用户配置 ==========
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "Vitus213";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      packages = with pkgs; [ ];
    };
    defaultUserShell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ username ];

  # ========== Nix 配置 ==========
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    builders-use-substitutes = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ========== 区域和时区 ==========
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };
  };

  # ========== 环境变量 ==========
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GOPROXY = "https://goproxy.cn,https://goproxy.io,direct";
  };
  environment.variables.EDITOR = "nvim";
  environment.shells = with pkgs; [ zsh ];

  # ========== 基础系统包 ==========
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    neofetch
    htop
    age
    sops
    lazygit
  ];

  # ========== 字体配置 ==========
  fonts = {
    packages = import ../../home/fonts-list.nix { inherit pkgs; };
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "FiraCode Nerd Font" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
    };
  };

  # ========== 安全配置 ==========
  security.rtkit.enable = true;
}
