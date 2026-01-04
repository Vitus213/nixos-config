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
	@printf "$(CYAN)Nix Configuration Makefile$(RESET)\n"
	@printf "==============================\n"
	@printf ""
	@printf "$(GREEN)NixOS 部署:$(RESET)\n"
	@printf "  make nixos-5600    - 部署到 Vitus5600 主机\n"
	@printf "  make nixos-8500    - 部署到 Vitus8500 主机\n"
	@printf ""
	@printf "$(GREEN)Darwin (macOS) 部署:$(RESET)\n"
	@printf "  make darwin        - 部署到 VitusMac\n"
	@printf "  make build-darwin  - 构建 Darwin 配置 (不部署)\n"
	@printf ""
	@printf "$(GREEN)Home Manager 部署:$(RESET)\n"
	@printf "  make home-ubuntu   - 部署 Ubuntu/Debian CLI 环境\n"
	@printf "  make home-wsl      - 部署 WSL CLI 环境\n"
	@printf ""
	@printf "$(GREEN)维护命令:$(RESET)\n"
	@printf "  make update        - 更新 flake.lock\n"
	@printf "  make clean         - 清理 generations\n"
	@printf "  make fmt           - 格式化 nix 文件\n"
	@printf "  make check         - 检查 flake 配置\n"
	@printf ""
	@printf "$(GREEN)Secrets 管理:$(RESET)\n"
	@printf "  make sops-edit     - 编辑 secrets.yaml\n"
	@printf "  make sops-decrypt  - 解密显示 secrets.yaml\n"
	@printf "  make sops-keys     - 显示配置 age 密钥\n"

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
	@printf "$(GREEN)清理完成$(RESET)\n"

clean-old: ## 清理超过 7 天的 generations
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d

fmt: ## 格式化所有 nix 文件
	@printf "$(CYAN)格式化所有 .nix 文件...$(RESET)\n"
	@find . -name "*.nix" -type f -not -path "./.git/*" | xargs nix fmt
	@printf "$(GREEN)格式化完成$(RESET)\n"

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
	@printf "$(CYAN)从 SSH 密钥生成 age 密钥:$(RESET)\n"
	@printf ""
	@printf "1. 生成私钥:\n"
	@printf "   $(YELLOW)mkdir -p ~/.config/sops/age$(RESET)\n"
	@printf "   $(YELLOW)ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt$(RESET)\n"
	@printf "   $(YELLOW)chmod 600 ~/.config/sops/age/keys.txt$(RESET)\n"
	@printf ""
	@printf "2. 获取公钥 (用于 .sops.yaml):\n"
	@printf "   $(YELLOW)ssh-to-age < ~/.ssh/id_ed25519.pub$(RESET)\n"
	@printf ""
	@printf "3. 将公钥添加到 .sops.yaml 中\n"

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
