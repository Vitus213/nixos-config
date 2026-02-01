#!/usr/bin/env bash
# 工作区切换脚本 - 模板文件替换版
# 用途：在双屏模式和单屏（副屏当主屏）模式之间切换

SCRIPT_DIR="$(dirname "$0")"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/conf"
MAIN_CONF="$CONFIG_DIR/5600.conf"
DUAL_TEMPLATE="$CONFIG_DIR/5600-dual.conf.template"
SINGLE_TEMPLATE="$CONFIG_DIR/5600-single.conf.template"
MODE_FILE="$HOME/.cache/hyprland_workspace_mode"

# 检查模板文件是否存在
if [ ! -f "$DUAL_TEMPLATE" ] || [ ! -f "$SINGLE_TEMPLATE" ]; then
    echo "错误：找不到配置模板文件"
    exit 1
fi

# 检查当前模式
if [ -f "$MODE_FILE" ]; then
    CURRENT_MODE=$(cat "$MODE_FILE")
else
    CURRENT_MODE="dual"
fi

# 切换到双屏模式
switch_to_dual() {
    echo "切换到双屏模式..."

    # 复制双屏模板
    cp "$DUAL_TEMPLATE" "$MAIN_CONF"

    echo "dual" > "$MODE_FILE"
    hyprctl reload
    notify-send "工作区模式" "已切换到双屏模式" -i video-display
}

# 切换到单屏模式
switch_to_single() {
    echo "切换到单屏模式..."

    # 复制单屏模板
    cp "$SINGLE_TEMPLATE" "$MAIN_CONF"

    echo "single" > "$MODE_FILE"
    hyprctl reload
    notify-send "工作区模式" "已切换到单屏模式（副屏当主屏）" -i video-display
}

# 主逻辑
case "${1:-}" in
    dual|双屏)
        switch_to_dual
        ;;
    single|单屏)
        switch_to_single
        ;;
    toggle|切换|"")
        if [ "$CURRENT_MODE" = "dual" ]; then
            switch_to_single
        else
            switch_to_dual
        fi
        ;;
    status|状态)
        echo "当前模式: $CURRENT_MODE"
        if [ "$CURRENT_MODE" = "dual" ]; then
            echo "双屏模式：右侧4K主屏(ws 1-4)，左侧2K副屏(ws 5)"
        else
            echo "单屏模式：2K显示器作为主屏(ws 1-5)"
        fi
        ;;
    *)
        echo "用法: $0 {dual|single|toggle|status}"
        echo ""
        echo "命令:"
        echo "  dual   双屏模式 - 右侧4K主屏(ws 1-4)，左侧2K副屏(ws 5)"
        echo "  single 单屏模式 - 2K显示器作为主屏(ws 1-5)"
        echo "  toggle 切换模式（默认）"
        echo "  status 查看当前模式"
        exit 1
        ;;
esac
