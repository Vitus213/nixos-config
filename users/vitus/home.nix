{ username, inputs, config, pkgs, unstable, ... }: {
  # 导入公共 home-manager 模块
  imports = [
    ./../../home/core.nix
    ./../../home/fcitx5
    ./../../home/programs
    ./../../home/shell
    ./../../home/linux/gui/base
    ./../../home/linux/gui/hyprland

  ];
  modules.desktop.hyprland.enable = true;
  home.packages = with pkgs; [ unstable.wechat-uos feishu qq ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
  programs.git = {
    enable = true;
    userName = "Vitus";
    userEmail = "zhzvitus@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "etc/nixos";
    };
  };

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

  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     env.TERM = "xterm-256color";
  #     font = { size = 12; };
  #     scrolling.multiplier = 5;
  #     selection.save_to_clipboard = true;
  #     window.opacity = 0.9;
  #     keyboard.bindings = [{
  #       key = "Q";
  #       mods = "Control|Shift";
  #       action = "Quit";
  #     }];
  #   };
  # };
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

