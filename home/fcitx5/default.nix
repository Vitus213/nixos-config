{ config, pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    # 如果用 fcitx5
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
      fcitx5-nord
    ];
    # fcitx5.waylandFrontend = true;
    # fcitx5.waylandFrontend = false;
    fcitx5.settings = {
      inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "rime";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "rime";
      };
    };
  };
}
