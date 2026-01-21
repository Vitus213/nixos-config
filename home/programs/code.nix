{
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./vscode.nix
  ];
  programs = {
    zed-editor = {
      enable = true;
      package = pkgs.zed-editor-fhs;
      extensions = [
        "nix"
      ];
      userSettings = {
        theme = lib.mkDefault "One Dark";
      };
      extraPackages = [
        pkgs.nixd
        pkgs.nil
      ];
      installRemoteServer = true;
    };
  };
  home.packages =
    with pkgs;
    [
      uv
      python314
      code-cursor
      unstable.claude-code
      vscode
      codex
      # 排版 (Typst)
      typst # 新一代科学排版语言和编译器。
      tinymist # Typst 的 LSP 服务器。
      # 开发工具 (Development Tools)
      fenix.complete.toolchain # Fenix 提供的完整 Rust 工具链。
      openjdk # 使用默认的 OpenJDK，支持 ARM64
      cmake # 跨平台构建系统生成器。
      nixfmt-rfc-style
      gnumake42
    ]
    ++ lib.optionals (!pkgs.stdenv.isAarch64) [
      # 这些包在 ARM64 macOS 上不下载，先跳过，用自带的
      llvmPackages_latest.libcxxClang # Clang 的 C++ 标准库。
      llvmPackages_latest.clang-tools # Clang 相关的开发工具 (如 linter, formatter)。
    ];

}
