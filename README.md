# nixos-config

This repository packages Vitus's personal NixOS and Home Manager setup as a flake so that different machines can share a common baseline while still keeping host specific hardware settings.

## Repository layout

```
.
├── flake.nix             # Flake entry point defining hosts and shared modules
├── flake.lock            # Pinned dependency revisions
├── hosts/                # Per-machine hardware profile and settings
│   ├── Vitus5600/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── Vitus8500/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/              # Reusable NixOS modules shared across hosts
│   └── system/
│       ├── system.nix    # Core system options (users, services, locales, fonts)
│       ├── packages.nix  # Global program toggles (Hyprland, Thunar, tailscale…)
│       └── nvidia.nix    # NVIDIA driver settings
├── users/                # User-level system options
│   └── vitus/
│       ├── nixos.nix     # Extra NixOS user configuration
│       └── home.nix      # Home Manager entry for user vitus
└── home/                 # Home Manager module collection
    ├── core.nix          # Home Manager base (state version, home directory)
    ├── fcitx5/           # Input method profile
    ├── linux/gui/        # Desktop UI pieces (base theme, Hyprland module)
    ├── programs/         # Application bundles grouped by purpose
    └── shell/            # Shell configuration (zsh, starship, terminals)
```

## How the pieces fit

- `flake.nix` wires together Nixpkgs (stable and unstable), Home Manager, overlays, and extra flakes such as Hyprland and vscode-server. Each host defined under `nixosConfigurations` combines its `hosts/<name>` directory with the shared modules and user profile.
- The reusable modules in `modules/system` provide the standard service stack (Wayland/Hyprland desktop, audio, printing, ssh, docker, tailscale, fonts, locale) so that hosts only need to deal with hardware specifics.
- Home Manager modules under `home/` are composed inside `users/vitus/home.nix`, which enables desktop features via the `modules.desktop.hyprland` option and layers in application groups (browsers, dev tools, media, etc.).
- Additional Home Manager tweaks, such as git identity or Wayland App settings, live alongside the modularized structure so they can be reused for future users or hosts if desired.

## Typical workflows

- Build and switch the target host locally:

  ```bash
  sudo nixos-rebuild switch --flake .#Vitus5600
  ```

- Apply only Home Manager changes for the user:

  ```bash
  home-manager switch --flake .#vitus@Vitus5600
  ```

- Update dependencies to the latest pinned versions:

  ```bash
  nix flake update
  ```

## Customization tips

- To add another machine, duplicate one of the `hosts/<name>` folders, adjust the `hardware-configuration.nix`, and list the new host in `flake.nix`.
- Shared system toggles belong in `modules/system`; if a setting is only relevant to a single host, keep it inside that host's `default.nix`.
- User-facing packages and dotfiles should be expressed through the Home Manager modules under `home/` so that they remain reproducible and easy to share.
- Secret values (tokens, SSH keys, passwords) should be moved out of the repository and injected through mechanisms such as `age`, `sops-nix`, or environment variables.

## Secret management

- The repository ships with [sops-nix](https://github.com/Mic92/sops-nix). Runtime decryption keys are generated under `/var/lib/sops-nix/keys.txt` and, by default, bound to the host SSH keys (`/etc/ssh/ssh_host_*`).
- To supply the GitHub access token used for `nix.settings.access-tokens-file`, copy `secrets/github-token.yaml.template` to `secrets/github-token.yaml`, replace the placeholder value, and encrypt it:

  ```bash
  sops --encrypt --age <age-recipient> secrets/github-token.yaml \
    > secrets/github-token.yaml.tmp
  mv secrets/github-token.yaml.tmp secrets/github-token.yaml
  ```

  The decrypted file must contain a single line in the form `github.com=<token>`.
- `secrets/.gitignore` ensures that plaintext or encrypted `.yaml` files stay out of version control. Keep your Age keys (for example `~/.config/sops/age/keys.txt`) private and back them up securely; they are required to re-encrypt or rotate secrets.
- For multiple machines, either share the generated Age key (`/var/lib/sops-nix/keys.txt`) or add additional recipients with `sops --add-age derivation`.
