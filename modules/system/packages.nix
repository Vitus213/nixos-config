{ pkgs, inputs, host, ... }: {

  programs = {  
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    nm-applet.indicator = true;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.tailscale.enable = true;
  nixpkgs.config.allowUnfree = true;
}
