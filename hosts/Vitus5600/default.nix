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
    #./../../modules/system/services.nix  # 其他系统服务
    ./../../modules/system/system.nix
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
  };


  


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
    # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
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

  networking.hostName = "Vitus5600"; # Define your hostname.

  #virtualization开启docker支持
  virtualisation.docker.enable = true;
  users.extraGroups.vboxusers.members = [ "vitus" ];



  security.rtkit.enable = true;
  #使用dbus
  services.dbus = {
    implementation = "broker";
    packages = [ pkgs.haskellPackages.dbus-app-launcher ];
  };
  system.stateVersion = "25.05"; # Did you read the comment?
}
