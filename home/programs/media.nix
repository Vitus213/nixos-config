{
  pkgs,
  config,
  lib,
  ...
}:
# media - control and enjoy audio/video
{
  # imports = [
  # ];

  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    wemeet
    # images
    imv
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = [ "gpu-hq" ];
      scripts = [ pkgs.mpvScripts.mpris ];
    };
    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
      plugins = with pkgs.obs-studio-plugins; [
        # obs-webkitgtk
        wlrobs
        waveform
        obs-vkcapture
        obs-tuna
      ];
    };
  };

  services = {
    playerctld.enable = true;
  };
}
