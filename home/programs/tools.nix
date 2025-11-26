{ pkgs, ... }: {
  home.packages = with pkgs; [
    appimage-run
    cpufrequtils
    curl
    git
    pciutils
    rofi
    wget
    zip
    bind
  ];
}
