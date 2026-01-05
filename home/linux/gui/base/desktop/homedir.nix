{ config, ... }:
let
  download = "download";
  music = "music";
  publicShare = "public";
  templates = ".template";
  videos = "video";
  pictures = "picture";
  documents = "document";
  desktop = ".desktop";
in
{
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    desktop = "${desktop}";
    download = "${download}";
    # documents = "${documents}";
    # music = "${music}";
    # pictures = "${pictures}";
    # publicShare = "${publicShare}";
    templates = "${templates}";
    # videos = "${videos}";
  };
}
