  {
    inputs,
    pkgs,
    username,
    config,
    lib,
    ...

  }:
  let cfg=config.modules.systemsecrets;
  in
  {

    options.modules.systemsecrets={
      enable = lib.mkOption{
        type = lib.types.bool;
        default =false;
        description = "Enable system sops secret management.";
      };
    };
    config=lib.mkIf cfg.enable{
sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    age.sshKeyPaths = [ "/home/${username}/.ssh/id_rsa" ];
    secrets.github_token = {
      owner = username;
    };
  };
   nix.settings.access-tokens = lib.mkIf (
      config.sops.secrets.github_token.path != null
    ) "github.com=$(cat ${config.sops.secrets.github_token.path})";
    };

  
  }
