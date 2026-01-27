{
  config,
  pkgs,
  lib,
  ...
}:

let
  proxyurl = "127.0.0.1:7897";

in
{
  options.modules.shell.enableProxy = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable proxy environment variables";
  };
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;
      dotDir = config.home.homeDirectory; # 锁定当前行为，消除警告

      autosuggestion = {
        enable = true;
      };

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
        #用nix编译dragonos
        test = ''
          if grep -q 'autotest = "syscall";' flake.nix; then
            sed -i 's/autotest = "syscall";/autotest = "none";/' flake.nix && \
            echo "✓ 已将 autotest 重置为 none"
          fi
          make kernel && nix run .#rootfs-x86_64 && nix run .#start-x86_64
        '';

        test-syscall = ''
          if grep -q 'autotest = "none";' flake.nix; then
            sed -i 's/autotest = "none";/autotest = "syscall";/' flake.nix && \
            echo "✓ 已将 autotest 从 none 改为 syscall"
          else
            echo "ℹ autotest 当前不是 none，无需修改"
          fi && make kernel && nix run .#rootfs-x86_64 && nix run .#start-x86_64
        '';
        t = "make kernel && nix run .#start-x86_64";
        gpush = "git add . && git commit -m \"update\" && git push";
        np = "unset http_proxy https_proxy all_proxy";
        p = "export http_proxy=http://${proxyurl} https_proxy=http://${proxyurl} all_proxy=socks5://${proxyurl}";
        ls = "ls --color=auto";
        la = "ls -a";
        ll = "ls -l";
        # Claude Code 快捷命令
        cf = "claude --dangerously-skip-permissions";
        cfc = "claude --dangerously-skip-permissions -c";
        # API 切换命令 (默认使用 AnyRouter)
        use-any = "export ANTHROPIC_AUTH_TOKEN=\"\${ANYROUTER_AUTH_TOKEN:-\$ANTHROPIC_AUTH_TOKEN}\" ANTHROPIC_BASE_URL=\"\${ANYROUTER_BASE_URL:-\$ANTHROPIC_BASE_URL}\" && echo 'Switched to AnyRouter API'";
        use-agent = "export ANTHROPIC_AUTH_TOKEN=\"\${AGENT_AUTH_TOKEN:-\$ANTHROPIC_AUTH_TOKEN}\" ANTHROPIC_BASE_URL=\"\${AGENT_BASE_URL:-\$ANTHROPIC_BASE_URL}\" && echo 'Switched to Agent API'";
        use-glm = "export ANTHROPIC_AUTH_TOKEN=\"\${GLM_AUTH_TOKEN:-\$ANTHROPIC_AUTH_TOKEN}\" ANTHROPIC_BASE_URL=\"\${GLM_BASE_URL:-\$ANTHROPIC_BASE_URL}\" && echo 'Switched to GLM API'";
      };

      sessionVariables = lib.mkMerge [
        (lib.mkIf config.modules.shell.enableProxy {
          http_proxy = "http://${proxyurl}";
          https_proxy = "http://${proxyurl}";
          all_proxy = "socks5://${proxyurl}";
          no_proxy = "localhost,127.0.0.1,::1";
        })
        {
          # 输入法设置
          # 在 Wayland 下，不应该设置 GTK_IM_MODULE 和 QT_IM_MODULE
          # GTK3/4 和 Qt 6.7+ 会自动使用 text-input-v3 协议
          # 设置这些变量会导致候选框位置错误和全屏时消失的问题
          # 参考: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
          #
          # XMODIFIERS 仍然需要，用于 XWayland 应用的 XIM 协议
          XMODIFIERS = "@im=fcitx";
        }
      ];
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

        # SOPS age 密钥文件 (Darwin & Linux)
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
        export SOPS_AGE_SSH_PRIVATE_KEY_FILE="$HOME/.ssh/id_rsa"

        # SOPS 密钥加载 (NixOS)
        if [ -f "/run/secrets/anyrouter_auth_token" ]; then
          export ANYROUTER_AUTH_TOKEN="$(cat /run/secrets/anyrouter_auth_token)"
          export ANTHROPIC_AUTH_TOKEN="$ANYROUTER_AUTH_TOKEN"
        fi
        if [ -f "/run/secrets/anyrouter_base_url" ]; then
          export ANYROUTER_BASE_URL="$(cat /run/secrets/anyrouter_base_url)"
          export ANTHROPIC_BASE_URL="$ANYROUTER_BASE_URL"
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
  };
}
