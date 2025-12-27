{
  inputs,
  pkgs,
  username,
  config,
  lib,
  ...

}:
let
  cfg = config.modules.systemsecrets;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  options.modules.systemsecrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable system sops secret management.";
    };
  };
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
      secrets.github_token = {
        owner = username;
        group = "users";
        mode = "0400";
      };
    };

    # 在用户登录时设置 GITHUB_TOKEN 和 NIX_CONFIG 环境变量
    # 这样 nix 命令就能使用 GitHub token
    # 注意：必须使用 extra-access-tokens 而不是 access-tokens
    # access-tokens 通过环境变量设置时不生效，这是 nix 的已知限制
    environment.extraInit = ''
      if [ -f "${config.sops.secrets.github_token.path}" ]; then
        export GITHUB_TOKEN="$(cat ${config.sops.secrets.github_token.path})"
        export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN"
      fi
    '';
  };
}
