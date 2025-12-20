# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  unstable,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # 导入自定义的通用系统模块
    ./../../modules/system/nvidia.nix # Nvidia 驱动
    ./../../modules/system/system.nix
  ];

  boot = {
    # loader.grub = {
    #         enable = true;
    #         device = "nodev";
    #         efiSupport = true;
    #         extraEntries = ''
    #             menuentry "Windows" {
    #                 search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
    #                 chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
    #             }
    #         '';
    #     };
    kernel.sysctl = {
      "net.ipv4.ip_forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";
  };

  networking.hostName = "Vitus5600"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
