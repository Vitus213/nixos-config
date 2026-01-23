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
      sops.age.sshKeyPaths = lib.mkForce [ ];
      secrets.github_token = {
        owner = username;
        group = "users";
        mode = "0400";
      };
    };

    environment.extraInit = ''
      if [ -f "${config.sops.secrets.github_token.path}" ]; then
        export GITHUB_TOKEN="$(cat ${config.sops.secrets.github_token.path})"
        export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN"
      fi
    '';
  };
}
