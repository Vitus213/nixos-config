{ pkgs, ... }: {
  home.packages = with pkgs; [
    fastfetch
    nvtopPackages.full
    hyfetch
    ipfetch
    neofetch
  ];

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = pkgs.stdenv.isLinux;
      rocmSupport = pkgs.stdenv.isLinux;
    };
  };

}
