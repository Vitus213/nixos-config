# home.nix 或你的 common-home.nix
{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
let
  # 根据平台选择正确的 home 目录
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{

  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml; # 注意相对路径可能要调整
    defaultSopsFormat = "yaml";
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";
    # 【重要】这里不需要写 owner = ...，因为 Home Manager 跑在用户态
    secrets.github_token = { };
    secrets.anthropic_auth_token = { };
    secrets.anthropic_base_url = { };

    # 这里加上刚才说的模板，自动生成 source 文件
    templates."my-env".content = ''
      export GITHUB_TOKEN="$(cat ${config.sops.secrets.github_token.path})"
        export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.anthropic_auth_token.path})"
        export ANTHROPIC_BASE_URL="$(cat ${config.sops.secrets.anthropic_base_url.path})"
    '';
  };
  # 让 shell 自动读取
  programs.zsh.initContent = ''
    if [[ -f "${config.xdg.configHome}/sops-nix/secrets/rendered/my-env" ]]; then
        source "${config.xdg.configHome}/sops-nix/secrets/rendered/my-env"
      fi
  '';
}
