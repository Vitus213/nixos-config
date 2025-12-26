{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      cpufetch
      smartmontools
      inetutils
      android-tools
      bat
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      cpuid
      cpu-x
      light
      lm_sensors
      lshw
    ];
}
