# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, unstable, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # 导入自定义的通用系统模块
    ./../../modules/system/desktop.nix # 桌面环境相关
    ./../../modules/system/nvidia.nix # Nvidia 驱动
    ./../../modules/system/network.nix # 网络相关
    #./../../modules/system/services.nix  # 其他系统服务
    ./../../modules/system/fonts.nix # 字体
    ./../../modules/system/users.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.access-tokens =
    "github.com=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";
  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Set your time zone.
  };
  #ipv4 and ipv6 forwarding

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
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-nord
      ];
    };
  };
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      IdleAction=ignore
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
    '';
  };
  #virtualization开启docker支持
  virtualisation.docker.enable = true;
  users.extraGroups.vboxusers.members = [ "vitus" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  environment.variables.EDITOR = "vim";
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
  security.rtkit.enable = true;
  #使用dbus
  services.dbus = {
    implementation = "broker";
    packages = [ pkgs.haskellPackages.dbus-app-launcher ];
  };
  system.stateVersion = "25.05"; # Did you read the comment?
}
