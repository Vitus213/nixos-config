{ config, nixpkgs, pkgs, ... }: {
  #添加一些常用的字体
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    #nerdfonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono # JetBrainsMono Nerd Font
    nerd-fonts.dejavu-sans-mono # DejaVuSansMono Nerd Font
    vista-fonts-chs
  ];

}
