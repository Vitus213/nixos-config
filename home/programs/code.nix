{
  lib,
  pkgs,
  unstable,
  ...
}:
{

  # programs = {
  #   zed-editor = {
  #     enable = true;
  #     package = pkgs.zed-editor;
  #     extensions = [ "nix" ];
  #     userSettings = {
  #       theme = lib.mkDefault "One Dark";
  #     };
  #     extraPackages = [
  #       pkgs.nixd
  #       pkgs.nil
  #     ];
  #     installRemoteServer = true;
  #   };
  # };

  home.packages =
    with pkgs;
    [
      uv
      python314

      unstable.claude-code

      codex
      # 排版 (Typst)
      typst
      tinymist
      # 基础开发工具 (通用)
      openjdk
      cmake
      nixfmt-rfc-style
      gnumake42
    ]
    # ========== 针对 Linux (NixOS/WSL) 的 Rust 配置 ==========
    ++ lib.optionals stdenv.isLinux [
      zed-editor
      code-cursor
      vscode
      fenix.stable.toolchain # Linux 上继续用 Fenix，享受组件组合的快感
    ]
    # ========== 针对 macOS (Darwin) 的 Rust 配置 ==========
    ++ lib.optionals stdenv.isDarwin [
      # macOS 上改用原生包，干爽、直接从二进制缓存下载
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy
    ]
    # ========== 其他平台特定的条件过滤 ==========
    ++ lib.optionals (!stdenv.isAarch64) [
      llvmPackages_latest.libcxxClang
      llvmPackages_latest.clang-tools
    ];
}
