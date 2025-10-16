{ pkgs, ... }: {
  programs.waybar.enable = true;
  programs.waybar.settings = {
    minibar = {
      layer = "top";
      position = "top";
      height = 30;
      outputs = [ "DP-0" "DP-2" ];
      modules-left = [ "wlr/taskbar" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "clock" ];
    };
  };

}
