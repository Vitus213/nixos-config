{
  pkgs,
  config,
  hostname,
  inputs,
  ...
}:
let
  # 使用 flake inputs 中的 hyprland，保持与系统级配置一致
  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  xdg.configFile =
    let
      repoConf = ./conf;
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      "hypr/configs".source = mkSymlink repoConf;
    };

  # xdg.configFile ={
  #   "hypr/configs".source = config.lib.file.mkOutOfStoreSymlink repoConf;
  # };
  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source =
        let
          configPath = "${config.home.homeDirectory}/.config/hypr/configs";
          hostSpecificHyprlandConfig =
            if hostname == "Vitus5600" then
              # 如果主机名是 "Vitus5600"，就导入 5600.nix 文件。
              "${configPath}/5600.conf"
            else if hostname == "Vitus8500" then
              # 如果主机名是 "Vitus8500"，就导入 8500.nix 文件。
              "${configPath}/8500.conf"
            else
              # 如果主机名不匹配任何已知的主机，则返回一个空配置集，不应用任何特定配置。
              { };
        in
        [
          hostSpecificHyprlandConfig
          "${configPath}/exec.conf"
          "${configPath}/fcitx5.conf"
          "${configPath}/keybindings.conf"
          "${configPath}/settings.conf"
          "${configPath}/windowrules.conf"
        ];
      env = [
      ];
    };
    # 启用 systemd 集成以正确设置会话环境变量
    # ly 显示管理器需要这些来正确启动 Hyprland 会话
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
  };
  services.polkit-gnome.enable = true; # polkit

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };
}
