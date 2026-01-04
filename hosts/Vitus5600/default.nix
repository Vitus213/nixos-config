{
  config,
  pkgs,
  inputs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";
  };

  networking.hostName = "Vitus5600";
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
