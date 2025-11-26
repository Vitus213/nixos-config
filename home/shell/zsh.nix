{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

    autosuggestion = { enable = true; };

    antidote = {
      enable = true;
      useFriendlyNames = true;
      plugins = [
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "romkatv/powerlevel10k"
      ];
    };

    history = {
      append = true;
      extended = true;
      save = 10000;
      size = 10000;
      ignoreDups = true;
    };

    shellAliases = {
      np = "unset http_proxy https_proxy all_proxy";
      p =
        "export http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897";
      ls = "ls --color=auto";
      la = "ls -a";
      ll = "ls -l";
    };
    sessionVariables = {
      http_proxy = "http://127.0.0.1:7897";
      https_proxy = "http://127.0.0.1:7897";
      all_proxy = "socks5://127.0.0.1:7897";
      no_proxy = "localhost,127.0.0.1,::1";

      # 输入法设置 (如果是 Home Manager 管理，可以在这里设；
      # 如果是 NixOS 系统级配置，通常在 i18n.inputMethod 中设置会自动生效)
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      if [ -f "/run/secrets/anthropic_auth_token" ]; then
        export ANTHROPIC_AUTH_TOKEN="$(cat /run/secrets/anthropic_auth_token)"
      fi
      if [ -f "/run/secrets/anthropic_base_url" ]; then
        export ANTHROPIC_BASE_URL="$(cat /run/secrets/anthropic_base_url)"
      fi
    '';
  };

  # Starship
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

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # 将你的 .p10k.zsh 放在这个模块的同级目录
  home.file."${config.home.homeDirectory}/.p10k.zsh".source = ./p10k.zsh;
}
