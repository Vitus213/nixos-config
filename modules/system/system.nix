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
      # define user packages here
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [ "~/.ssh/authorized_keys" ];
    };

    defaultUserShell = pkgs.zsh;

  };
  nix.settings.trusted-users = [ username ];
  nix.settings = {
    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    # # Configure console keymap
    # console.keyMap = "uk";

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    builders-use-substitutes = true;
    # access-tokens = lib.mkIf (
    #   config.sops.secrets.github_token.path != null
    # ) "github.com=$(cat ${config.sops.secrets.github_token.path})";
  };
  nix.gc = {
    automatic = true; # 开启自动清理
    dates = "weekly"; # 清理频率，可以设为 "daily"
    options = "--delete-older-than 30d"; # 删除 30 天前的版本
  };
  #桌面默认使用wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # 配置Go代理以解决sops-nix构建问题
  environment.sessionVariables.GOPROXY = "https://goproxy.cn,https://goproxy.io,direct";
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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  environment.variables.EDITOR = "nvim";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  services = {
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  # Services to start
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;
    displayManager.ly = {
      enable = true;
      settings = {
        default_user = "vitus";
        default_session = "Hyprland";
      };
    };
    #     displayManager.sddm={
    #     enable = true;
    #     settings.Autologin={
    #  User = "vitus";
    #       Session="hyprland";
    #     };
    #     };
  };
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    neofetch
    htop
    age
    sops
    lazygit
  ];
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
  # Select internationalisation properties.
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      IdleAction = "ignore";
      HandlePowerKey = "ignore";
      HandleSuspendKey = "ignore";
    };
  };

  #open ssh
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
    openFirewall = false;
  };

  #virtualization开启docker支持
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    registry-mirrors = [
      "https://docker.m.daocloud.io"
      "https://huecker.io"
      "https://dockerhub.timeweb.cloud"
    ];
  };
  systemd.services.docker.serviceConfig = {
    Environment = [
      "HTTP_PROXY=http://127.0.0.1:7897/"
      "HTTPS_PROXY=http://127.0.0.1:7897/"
      "NO_PROXY=localhost,127.0.0.1"
    ];
  };
  users.extraGroups.vboxusers.members = [ "vitus" ];

  security.rtkit.enable = true;
  #使用dbus
  services.dbus = {
    enable = true;
    # implementation = "broker";
    # packages = [ pkgs.haskellPackages.dbus-app-launcher ];
  };
}
