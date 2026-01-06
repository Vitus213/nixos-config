{
  username,
  inputs,
  config,
  pkgs,
  unstable,
  ...
}:
{
  # 导入公共 home-manager 模块
  imports = [
    ./../../home/core.nix
    ./../../home/programs
    ./../../home/shell
    ./../../home/linux/gui/base
    ./../../home/fcitx5
    ./../../home/linux/gui/hyprland

  ];
  modules.secrets.enable = true; # 启用用户级sops以渲染环境变量和gh配置
  modules.desktop.hyprland.enable = true; # Enable Hyprland
  home.packages = with pkgs; [
    wechat  # 暂时禁用，网络下载失败
    feishu
    qq
  ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];

  # 启用 starship，这是一个漂亮的 shell 提示符,
  #zsh的p10k会覆盖starship，但是bash会用上
  programs.starship = {
    enable = true;
    settings = {
      username = {
        disabled = false;
        show_always = true;
      };
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = false;
    };
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = "";
  };

  # 如果你使用 zoxide，并且它有自己的顶层启用选项
  #自动跳转
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  services.kdeconnect.enable = true;
}
