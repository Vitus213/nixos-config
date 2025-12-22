{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      cpufetch
      smartmontools
      inetutils
      android-tools
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      cpuid
      cpu-x
      light
      lm_sensors
      lshw
    ];
}
