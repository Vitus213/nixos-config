{ pkgs, inputs, host, ... }: {

  programs = {
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    nm-applet.indicator = true;
    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
    zsh.enable = true;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.tailscale.enable = true;
  nixpkgs.config.allowUnfree = true;
}
