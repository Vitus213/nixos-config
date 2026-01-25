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
  imports = [ inputs.sops-nix.darwinModules.sops ];
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
      age = {
        keyFile = "/Users/${username}/.config/sops/age/keys.txt";
        sshKeyPaths = lib.mkForce [ ];
        generateKey = false;
      };
      # 明确禁用 GPG（确保只使用 age）
      gnupg = {
        home = null;
        sshKeyPaths = lib.mkForce [ ];
      };
      secrets.github_token = {
        owner = "root";
        group = "staff";
        mode = "0400";
      };
    };

    # 在用户配置目录创建 nix.conf 以覆盖系统配置
    system.activationScripts.extraActivation.text = ''
      echo "Setting up GitHub access token for nix..."
      if [ -f /run/secrets/github_token ]; then
        TOKEN=$(cat /run/secrets/github_token)
        mkdir -p /Users/${username}/.config/nix
        echo "access-tokens = github.com=$TOKEN" > /Users/${username}/.config/nix/nix.conf
        chown -R ${username}:staff /Users/${username}/.config/nix
        echo "GitHub access token configured in user nix.conf"
      fi
    '';
  };
}
