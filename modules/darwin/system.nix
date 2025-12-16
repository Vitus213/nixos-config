# Darwin 系统配置
{ pkgs, ... }:

{
  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true;
    };
  };

  # Add ability to use TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Environment variables
  environment.variables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    TERM = "xterm-256color";
    COLORTERM = "truecolor";
  };
}
