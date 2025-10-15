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

    initContent = ''
        alias ls="ls --color=auto"
        alias la="ls -a"
        alias ll="ls -l"
         [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ex

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
