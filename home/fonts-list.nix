{ pkgs }:
# 公共字体列表，可以在系统级和 home-manager 中共享
with pkgs; [
  dejavu_fonts
  fira-code
  fira-code-symbols
  nerd-fonts.fira-code
  font-awesome
  hackgen-nf-font
  ibm-plex
  inter
  jetbrains-mono
  material-icons
  maple-mono.NF
  minecraftia
  noto-fonts
  noto-fonts-color-emoji
  noto-fonts-cjk-sans
  noto-fonts-cjk-serif
  noto-fonts-monochrome-emoji
  powerline-fonts
  roboto
  roboto-mono
  symbola
  terminus_font
  liberation_ttf
  mplus-outline-fonts.githubRelease
  dina-font
  # proggyfonts  # 与 dina-font 冲突，已移除
  nerd-fonts.jetbrains-mono
  nerd-fonts.dejavu-sans-mono
  vista-fonts-chs
]
