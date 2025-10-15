{ username, inputs, config, pkgs, unstable, ... }: {
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.

  # Services to start
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true; # 支持 Wayland 会话
      theme = "breeze"; # Plasma 默认主题
    };
    #用sddm
    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       user = "vitus";
    #       command =
    #         "${unstable.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
    #     };
    #   };
    # };
  };

  # Configure console keymap
  console.keyMap = "uk";
  #桌面默认使用wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # enable hyprland 
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
