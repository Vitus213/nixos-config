#无法作用。
final: prev:{
  rime-data = ./rime-data-vitus;
  fcitx5-rime = prev.fcitx5-rime.override { rimeDataPkgs = [ ./rime-data-vitus ]; };

  # used by macOS Squirrel
  flypy-squirrel = ./rime-data-vitus;
}
