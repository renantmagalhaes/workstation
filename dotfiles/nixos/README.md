# NixOS Workstation Configuration

This directory contains the declarative NixOS configuration for the `workstation` host.

## ⚠️ Important Note: Flatpak Migration

As of April 2026, several applications have been migrated from native Nix packages to **Flatpak** for security and stability reasons.

### Applications Migrated:
*   **Plex Desktop** (`tv.plex.PlexDesktop`)
*   **Stremio** (`com.stremio.Stremio`)
*   **CopyQ** (`com.github.hluk.copyq`)

### Rationale:
These applications depend on `qtwebengine-5.15.x`, which is officially marked as **Insecure** and **End-of-Life** in Nixpkgs. It is based on an outdated version of Chromium (v87) and is no longer receiving security patches.
*   **Nix Strategy**: Refuses to build these packages without explicit security overrides.
*   **Flatpak Strategy**: Provides these apps in a containerized environment (bubblewrap sandbox), which is safer than running them natively with unpatched libraries.

### ZSH Navigation Hardening (Smart CD)
The custom `cd` function in `functions.zsh` has been hardened to prevent "Smart" interactive features (like the parent directory climber) from being triggered by background processes or plugins (e.g., `zoxide`). 
- **Interactivity Check**: Interactive menus only trigger if `[[ -t 0 ]]` (stdin is a terminal).
- **Automation Friendly**: Non-interactive calls to `cd` now fallback safely to `builtin cd`.

### Future Action:
Periodically check if these applications have been updated to **Qt 6** (which uses a modern, secure WebEngine). Once they are on Qt 6, they can be safely moved back to native Nix packages in `modules/packages.nix`.

## Component Overview:
*   `flake.nix`: Main entry point. Uses `nix-flatpak` for declarative Flatpaks.
*   `modules/flatpaks.nix`: List of managed Flatpak applications.
*   `modules/packages.nix`: Native system-wide Nix packages.
*   `home-manager/`: User-level configuration and ZSH setup.

# TESTS
sync 12
