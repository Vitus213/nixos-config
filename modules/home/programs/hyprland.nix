{ inputs, config, pkgs, ... }: {
  wayland.windowManager.hyprland.settings = {
    decoration = {
      shadow_offset = "0 5";
      "col.shadow" = "rgba(00000099)";
    };

    "$mod" = "SUPER";

    bindm = [
      # mouse movements
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];
  };
  wayland.windowManager.hyprland = {
    enable = true;

    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.PLUGIN_NAME
    # ];
  };
}
