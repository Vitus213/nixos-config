{ pkgs, config, ... }:
{
  # 将 sops 生成的 gh-hosts 链接到 gh 配置目录
  xdg.configFile."gh/hosts.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sops-nix/secrets/rendered/gh-hosts";

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.git = {
    enable = true;
    userName = "Vitus213";
    userEmail = "zhzvitus@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "etc/nixos";
    };
  };
}
