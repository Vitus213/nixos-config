{
  config,
  ...
}:
{
  # ========== 网络配置 ==========
  networking.networkmanager.enable = true;

  # ========== OpenSSH ==========
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
    openFirewall = false;
  };

  # ========== Tailscale VPN ==========
  services.tailscale.enable = true;

  # ========== Docker ==========
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    registry-mirrors = [
      "https://docker.m.daocloud.io"
      "https://huecker.io"
      "https://dockerhub.timeweb.cloud"
    ];
  };

  # Docker 代理配置（如果需要）
  systemd.services.docker.serviceConfig = {
    Environment = [
      "HTTP_PROXY=http://127.0.0.1:7897/"
      "HTTPS_PROXY=http://127.0.0.1:7897/"
      "NO_PROXY=localhost,127.0.0.1"
    ];
  };
}
