#!/bin/bash

PLIST_PATH="/Library/LaunchDaemons/org.nixos.nix-daemon.plist"
PROXY="http://127.0.0.1:7897" # 确认这是你的代理端口

echo "正在从系统提取最新的 nix-daemon 路径..."
# 动态提取当前存在的 ProgramArguments 路径
DAEMON_PATH=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments" $PLIST_PATH | grep "/nix/store" | tail -n 1 | sed 's/^[[:space:]]*//')

echo "当前路径为: $DAEMON_PATH"

echo "正在注入代理变量并重启服务..."
sudo launchctl unload $PLIST_PATH

# 注入环境变量
sudo /usr/libexec/PlistBuddy -c "Delete :EnvironmentVariables" $PLIST_PATH 2>/dev/null
sudo /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables dict" $PLIST_PATH
sudo /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:http_proxy string $PROXY" $PLIST_PATH
sudo /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:https_proxy string $PROXY" $PLIST_PATH
sudo /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:OBJC_DISABLE_INITIALIZE_FORK_SAFETY string YES" $PLIST_PATH

sudo launchctl load $PLIST_PATH
echo "✅ 搞定！代理已注入。"
