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
    secrets.github_token = {
      owner = "root";
      group = "root";
      mode="0400";
    };
  };
  # nix.extraOptions=''
  #   !include ${config.sops.secrets.github_system_token.path}
  # '';
  nix.settings.access-tokens = [
  "github.com=$(cat ${config.sops.secrets.github_token.path})"
];

  
  };
  }
