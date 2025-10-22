{config,pkgs,...}:{

  services.hypridle={
    enable =true;
    package =pkgs.hypridle;
    settings={
      general = {
    # 锁屏命令，通常是你的锁屏程序，如 swaylock 或 gtklock
    lock_cmd = "hyprlock";                  # 示例：使用 swaylock 锁屏
    # unlock_cmd = notify-send "unlock!"      # 解锁命令，通常不需要手动设置  # 系统进入睡眠前执行的命令
    before_sleep_cmd = "hyprlock"; # 系统进入睡眠前执行的命令
    after_sleep_cmd = "hyprctl dispatch dpms on"; # 系统从睡眠唤醒后执行的命令
    ignore_dbus_inhibit = false;
    ignore_systemd_inhibit = false;
};

listener = [
    {
      timeout = 900;
      on-timeout = "hyprlock";
    }
    {
      timeout = 1800;
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";

    }
  ];
    };
  };
}