# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, unstable, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # 导入自定义的通用系统模块
    ./../../modules/system/nvidia.nix # Nvidia 驱动
    #./../../modules/system/services.nix  # 其他系统服务
    ./../../modules/system/system.nix
  ];

  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking.hostName = "Vitus5600"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
