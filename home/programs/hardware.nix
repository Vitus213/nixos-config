{ pkgs, ... }: {
  home.packages = with pkgs;
    [ cpufetch smartmontools inetutils ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      cpuid
      cpu-x
      light
      lm_sensors
      lshw
    ];
}
