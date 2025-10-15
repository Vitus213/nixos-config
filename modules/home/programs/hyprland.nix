{ inputs, config, pkgs, ... }: {
  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
  # Use the same hyprland package coming from the flake inputs to avoid
  # version/protocol mismatches between system and user packages.
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;
  };
  home.file."~/.config/hypr/hyprland.conf".source = ./hyprland.conf;
}
