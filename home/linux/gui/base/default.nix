# { mylib, ... }:
# {
#   imports = mylib.scanPaths ./.;
# }
{ imports = [ ./wayland-apps.nix ./xdg.nix ]; }