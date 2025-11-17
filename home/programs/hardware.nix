{ pkgs, ... }: {
  home.packages = with pkgs; [
    cpufetch
    cpuid
    cpu-x
    smartmontools
    light
    lm_sensors
    lshw
    inetutils
  ];
}
