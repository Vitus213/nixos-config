{ inputs, config, pkgs, ... }: {
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  # # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable =false;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Configure console keymap
  console.keyMap = "uk";
  #桌面默认使用wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # # enable hyprland 
  # programs.hyprland = {
  #   enable = true;
  #   # set the flake package
  #   package =
  #     inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   # make sure to also set the portal package, so that they are in sync
  #   portalPackage =
  #     inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  # };
}
