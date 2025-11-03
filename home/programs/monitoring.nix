{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    nvtopPackages.full
    atop
    hyfetch
    ipfetch
    neofetch
  ];

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    };
  };
}
