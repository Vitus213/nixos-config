{ config, pkgs, ... }:
let
  typst = {
    extensions = with pkgs.vscode-extensions; [
      myriad-dreamin.tinymist
      Google.gemini-cli-vscode-ide-companion
      tomoki1207.pdf
    ];
    userSettings = {
      "files.autoSave" = "off";
    };
  };
in
{
  programs.vscode = {
    enable = true;
    profiles.typst = typst;
  };
  
}
