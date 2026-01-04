{
  pkgs,
  config,
  ...
}:
{
  # ========== 音频 (PipeWire) ==========
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ========== 蓝牙 ==========
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ========== X Server ==========
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # ========== 打印服务 ==========
  services.printing.enable = true;

  # ========== 电源管理 ==========
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      IdleAction = "ignore";
      HandlePowerKey = "ignore";
      HandleSuspendKey = "ignore";
    };
  };

  # ========== D-Bus ==========
  services.dbus.enable = true;

  # ========== 显示管理器 (ly) ==========
  services.displayManager.ly = {
    enable = true;
    settings = {
      default_user = "vitus";
      default_session = "Hyprland";
    };
  };
}
