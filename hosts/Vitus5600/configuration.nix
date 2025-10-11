# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, unstable, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # 导入自定义的通用系统模块
    ./../../modules/system/base.nix # 基础设置
    ./../../modules/system/desktop.nix # 桌面环境相关
    ./../../modules/system/nvidia.nix # Nvidia 驱动
    ./../../modules/system/network.nix # 网络相关
    #./../../modules/system/services.nix  # 其他系统服务
    ./../../modules/system/fonts.nix # 字体
  ];
  networking.hostName = "Vitus5600"; # Define your hostname.
  #用户
  users.users.vitus = {
    isNormalUser = true;
    description = "VitusApollo";
    extraGroups =
      [ "networkmanager" "wheel" "docker" "wireshark" "adbusers" "kvm" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "~/.ssh/authorized_keys" ];
    #软件包
    packages = with pkgs;
      [
        kdePackages.kate
        #  thunderbird
      ];
  };
  environment.systemPackages = with pkgs; [
    vim-full
    git
    wget
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.access-tokens =
    "github.com=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";

  #virtualization开启docker支持
  virtualisation.docker.enable = true;
  users.extraGroups.vboxusers.members = [ "vitus" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  environment.variables.EDITOR = "vim";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # use th fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-chinese-addons
      fcitx5-nord
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  #配置wireshark
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
  };
  programs.zsh.enable = true;
  # Install firefox.
  programs.firefox.enable = true;
  programs.direnv.enable = true;
  programs.adb.enable = true;
  programs.steam.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #使用dbus
  services.dbus = {
    implementation = "broker";
    packages = [ pkgs.haskellPackages.dbus-app-launcher ];
  };

  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?

}
