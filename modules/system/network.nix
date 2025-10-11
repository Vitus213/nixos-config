{ config, nixpkgs, pkgs, ... }: {
  # Enable networking
  networking.networkmanager.enable = true;
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
