{ config, pkgs, lib, ... }:

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
      # Claude Code 快捷命令
      cf = "claude --dangerously-skip-permissions";
      cfc = "claude --dangerously-skip-permissions -c";
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

      # Cargo/Rust 环境
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

      # Home Manager 包路径 (仅 macOS/Darwin 需要)
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        PATH="/etc/profiles/per-user/$USER/bin:$PATH"
      ''}

      # 交叉编译工具链 PATH
      PATH="$HOME/.cargo/bin:$PATH"
      PATH="$PATH:$HOME/opt/x86_64-linux-musl-cross-gcc-9.4.0/bin"
      PATH="$PATH:$HOME/opt/riscv64-linux-musl-cross-gcc-9.4.0/bin"
      PATH="$PATH:$HOME/opt/loongarch64-cross-14.2.0/bin"
      export PATH
      export SOPS_AGE_SSH_PRIVATE_KEY_FILE="$HOME/.ssh/id_rsa"
      # SOPS 密钥加载 (NixOS)
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
