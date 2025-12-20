# Darwin 应用程序配置
{ pkgs, ... }:

{
  # Install packages from nix's official package repository.
  environment.systemPackages = with pkgs; [
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-powerlevel10k
    bat
    eza
    ripgrep
    fd
    htop
    ncdu
    tree
    jq
    tldr
    direnv
  ];

  # Homebrew configuration
  # NOTE: homebrew need to be installed manually first, see https://brew.sh
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # cleanup = "zap";
    };

    taps = [ "homebrew/services" ];

    # `brew install`
    brews = [ "aria2" ];

    # `brew install --cask`
    casks = [ "microsoft-edge" "notion" "obsidian" ];
  };

  # Configure programs that integrate with zsh
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
