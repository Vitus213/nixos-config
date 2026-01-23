{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [

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
      cpufetch
      psmisc
    ];
}
