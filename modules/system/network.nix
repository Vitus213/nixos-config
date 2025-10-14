{ config, nixpkgs, pkgs, ... }: {
  networking.hostName = "Vitus5600"; # Define your hostname.
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
}
