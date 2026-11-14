#!/bin/bash
set -e

# ==============================================================================
# Neovim & Vim Setup Script
# Workstation Custom IDE Distribution (Stable, Robust & Low-Maintenance)
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_NVIM="$REPO_DIR/dotfiles/nvim"
CONFIG_NVIM="$HOME/.config/nvim"

echo "=============================================="
echo "🚀 Setting up Neovim Custom IDE Distribution"
echo "=============================================="

# 1. Ensure Homebrew environment is active if present
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add common local paths to PATH for this script execution
export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:$PATH"

# 2. Legacy Vimrc settings (safe if ~/.vim is not writable)
mkdir -p "$HOME/.vim" 2>/dev/null || true
if [ -d "$HOME/.vim" ]; then
    touch "$HOME/.vim/vimrc" 2>/dev/null || true
    if [ -w "$HOME/.vim/vimrc" ]; then
        grep -q "set ignorecase" "$HOME/.vim/vimrc" || echo "set ignorecase" >> "$HOME/.vim/vimrc"
        grep -q "set cryptmethod=blowfish2" "$HOME/.vim/vimrc" || echo "set cryptmethod=blowfish2" >> "$HOME/.vim/vimrc"
        grep -q "set viminfo=" "$HOME/.vim/vimrc" || echo "set viminfo=" >> "$HOME/.vim/vimrc"
    fi
fi

# 3. Clean up previous broken distribution caches (LazyVim state)
echo "🧹 Cleaning up old Neovim caches..."
rm -rf "$HOME/.cache/nvim" 2>/dev/null || true
rm -rf "$HOME/.local/state/nvim" 2>/dev/null || true

# Ensure nvim-treesitter is on main branch (required for Neovim 0.12+)
TREESITTER_DIR="$HOME/.local/share/nvim/lazy/nvim-treesitter"
if [ -d "$TREESITTER_DIR/.git" ]; then
    (cd "$TREESITTER_DIR" && git checkout main 2>/dev/null || git pull origin main 2>/dev/null || true)
fi

# 4. Link dotfiles/nvim to ~/.config/nvim
mkdir -p "$HOME/.config" 2>/dev/null || true
if [ -e "$CONFIG_NVIM" ] && [ ! -L "$CONFIG_NVIM" ]; then
    BACKUP="$CONFIG_NVIM.backup.$(date +%Y%m%d%H%M%S)"
    echo "📦 Backing up existing non-symlink ~/.config/nvim to $BACKUP"
    mv "$CONFIG_NVIM" "$BACKUP" 2>/dev/null || true
fi

ln -sfn "$DOTFILES_NVIM" "$CONFIG_NVIM" 2>/dev/null || true
echo "🔗 Symlinked: $CONFIG_NVIM -> $DOTFILES_NVIM"

# 5. Bootstrap lazy.nvim plugin manager if not present
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
    echo "📥 Bootstrapping lazy.nvim plugin manager..."
    mkdir -p "$(dirname "$LAZY_DIR")" 2>/dev/null || true
    git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_DIR" 2>/dev/null || true
fi

# 6. Verify nvim binary
NVIM_BIN="$(command -v nvim || true)"
if [ -z "$NVIM_BIN" ]; then
    if [ -x "/home/linuxbrew/.linuxbrew/bin/nvim" ]; then
        NVIM_BIN="/home/linuxbrew/.linuxbrew/bin/nvim"
    elif [ -x "/opt/homebrew/bin/nvim" ]; then
        NVIM_BIN="/opt/homebrew/bin/nvim"
    fi
fi

if [ -n "$NVIM_BIN" ]; then
    echo "✨ Found Neovim at: $NVIM_BIN"
    echo "🔒 Pre-installing and restoring plugins headlessly from lazy-lock.json..."
    "$NVIM_BIN" --headless "+Lazy! restore" +qa || "$NVIM_BIN" --headless "+Lazy! sync" +qa || true
    echo "✅ Plugins installed and locked to exact commits!"
else
    echo "ℹ️  Neovim binary not in PATH during script execution."
    echo "   Ensure Homebrew's Neovim is in PATH: eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
    echo "   Once you open nvim, lazy.nvim will automatically install all plugins on first launch."
fi

echo ""
echo "=============================================="
echo "🎉 Setup complete! Keybindings Summary:"
echo "----------------------------------------------"
echo "  • Lateral Tree:        <leader>e or <Ctrl+b>"
echo "  • Fuzzy Search Inline: <Ctrl+f> or <leader>f"
echo "  • Fuzzy Search Folder: <Space><Space>"
echo "  • Live Grep Project:   <leader>fg or <leader>/"
echo "  • Save File:           <Ctrl+s> (Normal/Insert/Visual)"
echo "  • Exit with Prompt:    <Ctrl+d> (Prompts if modified!)"
echo "  • Pretty JSON:         <leader>pj or :PrettyJson"
echo "  • Paste Image:         <leader>p or <leader>P"
echo "  • LazyGit:             <leader>gg or <leader>lg"
echo "  • Markdown Preview:    <leader>mp"
echo "  • Format Document:     <leader>cf or <leader>fm"
echo "  • Diagnostics List:    <leader>xx"
echo "  • Buffer Tabs:         [b / ]b / <leader>1-9"
echo "=============================================="
