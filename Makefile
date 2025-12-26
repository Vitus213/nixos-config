# Makefile for NixOS and nix-darwin configurations
# ================================================

# 使用系统默认 shell (兼容 NixOS)
SHELL := /bin/sh

.PHONY: help nixos-5600 nixos-8500 darwin home-ubuntu home-wsl update clean fmt check test build-darwin sops-edit sops-decrypt

# 默认目标
.DEFAULT_GOAL := help

# 颜色定义
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RESET := \033[0m

help: ## 显示帮助信息
	@echo "$(CYAN)Nix Configuration Makefile$(RESET)"
	@echo "=============================="
	@echo ""
	@echo "$(GREEN)NixOS 部署:$(RESET)"
	@echo "  make nixos-5600    - 部署到 Vitus5600 主机"
	@echo "  make nixos-8500    - 部署到 Vitus8500 主机"
	@echo ""
	@echo "$(GREEN)Darwin (macOS) 部署:$(RESET)"
	@echo "  make darwin        - 部署到 VitusMac"
	@echo "  make build-darwin  - 构建 Darwin 配置 (不部署)"
	@echo ""
	@echo "$(GREEN)Home Manager 部署:$(RESET)"
	@echo "  make home-ubuntu   - 部署 Ubuntu/Debian CLI 环境"
	@echo "  make home-wsl      - 部署 WSL CLI 环境"
	@echo ""
	@echo "$(GREEN)维护命令:$(RESET)"
	@echo "  make update        - 更新 flake.lock"
	@echo "  make clean         - 清理 generations"
	@echo "  make fmt           - 格式化 nix 文件"
	@echo "  make check         - 检查 flake 配置"
	@echo ""
	@echo "$(GREEN)Secrets 管理:$(RESET)"
	@echo "  make sops-edit     - 编辑 secrets.yaml"
	@echo "  make sops-decrypt  - 解密显示 secrets.yaml"
	@echo "  make sops-keys     - 显示配置 age 密钥"

# ========== NixOS 部署 ==========

nixos-5600: ## 部署到 Vitus5600 (NixOS + Nvidia)
	sudo nixos-rebuild switch --flake .#Vitus5600

nixos-8500: ## 部署到 Vitus8500 (NixOS)
	sudo nixos-rebuild switch --flake .#Vitus8500

nixos-boot: ## 构建并设为下次启动 (不立即切换)
	sudo nixos-rebuild boot --flake .#$(shell hostname)

nixos-test: ## 测试配置 (不持久化)
	sudo nixos-rebuild test --flake .#$(shell hostname)

# ========== Darwin (macOS) 部署 ==========
mac:
	nix build .#darwinConfigurations.VitusMac.system \
	   --extra-experimental-features 'nix-command flakes'

	sudo -E ./result/sw/bin/darwin-rebuild switch --flake .#VitusMac
# ========== Home Manager 部署 ==========

home-ubuntu: ## 部署 Ubuntu/Debian CLI 环境
	home-manager switch --flake .#vitus@ubuntu

home-wsl: ## 部署 WSL CLI 环境
	home-manager switch --flake .#vitus@wsl

# ========== 维护命令 ==========

update: ## 更新 flake inputs
	nix flake update

update-input: ## 更新指定 input (用法: make update-input INPUT=nixpkgs)
	nix flake lock --update-input $(INPUT)

clean: ## 清理 generations (保留最近 5 个)
	sudo nix-collect-garbage -d
	nix-collect-garbage -d
	@echo "$(GREEN)清理完成$(RESET)"

clean-old: ## 清理超过 7 天的 generations
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d

fmt: ## 格式化所有 nix 文件
	@echo "$(CYAN)格式化所有 .nix 文件...$(RESET)"
	@find . -name "*.nix" -type f -not -path "./.git/*" | xargs nix fmt
	@echo "$(GREEN)格式化完成$(RESET)"

check: ## 检查 flake 配置
	nix flake check

show: ## 显示 flake 输出
	nix flake show

# ========== Secrets 管理 ==========

sops-edit: ## 编辑 secrets.yaml
	sops secrets/secrets.yaml

sops-decrypt: ## 解密显示 secrets.yaml
	sops -d secrets/secrets.yaml

sops-keys: ## 显示配置 age 密钥
	@echo "$(CYAN)从 SSH 密钥生成 age 密钥:$(RESET)"
	@echo ""
	@echo "1. 生成私钥:"
	@echo "   $(YELLOW)mkdir -p ~/.config/sops/age$(RESET)"
	@echo "   $(YELLOW)ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt$(RESET)"
	@echo "   $(YELLOW)chmod 600 ~/.config/sops/age/keys.txt$(RESET)"
	@echo ""
	@echo "2. 获取公钥 (用于 .sops.yaml):"
	@echo "   $(YELLOW)ssh-to-age < ~/.ssh/id_ed25519.pub$(RESET)"
	@echo ""
	@echo "3. 将公钥添加到 .sops.yaml 中"

sops-rekey: ## 重新加密 secrets (更换密钥后)
	sops updatekeys secrets/secrets.yaml

# ========== 调试工具 ==========

repl: ## 进入 nix repl
	nix repl .#

gc-roots: ## 显示 GC roots
	nix-store --gc --print-roots | grep -v '/proc/'

disk-usage: ## 显示 nix store 磁盘占用
	nix path-info -Sh /run/current-system
	@echo ""
	du -sh /nix/store

# ========== Git 快捷方式 ==========

diff: ## 显示未提交的更改
	git diff

status: ## 显示 git 状态
	git status

push: ## 推送到远程仓库
	git push origin main
