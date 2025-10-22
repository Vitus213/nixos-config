{ pkgs, lib, username, ... }: {
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "Vitus213";
      extraGroups = [ "networkmanager" "wheel" ];
      # define user packages here
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [ "~/.ssh/authorized_keys" ];
    };

    defaultUserShell = pkgs.zsh;

  };
  nix.settings.trusted-users = [ username ];
  nix.settings = {
    # enable flakes globally
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    # # Configure console keymap
    # console.keyMap = "uk";

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    builders-use-substitutes = true;

    access-tokens =
      "github.com=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";
  };
  #桌面默认使用wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };

  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  environment.variables.EDITOR = "neovim";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  services = {
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  # Services to start
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
    displayManager.ly = {
      enable = true;
      settings = {
        default_user = "vitus";
        default_session = "hyprland";
      };
    };

  };
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    neofetch
    htop
  ];
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      fira-code-nerdfont
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      jetbrains-mono
      material-icons
      maple-mono.NF
      minecraftia
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      symbola
      terminus_font
      liberation_ttf
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.dejavu-sans-mono
      vista-fonts-chs
    ];
    fontconfig = {
    antialias = true;
    hinting.enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "FiraCode Nerd Font" ];
      sansSerif = [ "Noto Sans CJK SC" ];
      serif = [ "Noto Serif CJK SC" ];
    };
  };
  };
  # Select internationalisation properties.
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      IdleAction=ignore
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
    '';
  };

  #open ssh
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
    openFirewall = false;
  };

  #virtualization开启docker支持
  virtualisation.docker.enable = true;
  users.extraGroups.vboxusers.members = [ "vitus" ];

  security.rtkit.enable = true;
  #使用dbus
  services.dbus = {
    implementation = "broker";
    packages = [ pkgs.haskellPackages.dbus-app-launcher ];
  };
}
