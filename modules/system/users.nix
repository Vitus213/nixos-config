{ pkgs, ... }: {
  users = {
    mutableUsers = true;
    users."vitus" = {
      homeMode = "755";
      isNormalUser = true;
      description = "Vitus213";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
      ];

      # define user packages here
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [ "~/.ssh/authorized_keys" ];
    };

    defaultUserShell = pkgs.zsh;

  };

  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [ lsd fzf ];
}
