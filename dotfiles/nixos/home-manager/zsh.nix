{ config, pkgs, inputs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh-My-Zsh setup
    oh-my-zsh = {
      enable = true;
      plugins = [
        # Core git
        "git" "git-auto-fetch"
        # Containers
        "docker" "docker-compose"
        # Cloud / infra
        "kubectl" "aws" "tmux"
        # Shell quality-of-life
        "colored-man-pages" "colorize" "virtualenv"
        "copyfile" "copybuffer" "copypath"
        "systemadmin" "rsync"
        # Already present
        "fzf" "sudo" "extract" "ssh-agent"
        # command-not-found intentionally omitted — needs nix-index on NixOS
      ];
      theme = "robbyrussell";
    };

    # Additional custom plugins via Nixpkgs
    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }
    ];

    # 1. EARLY INITIALIZATION (NixOS 25.11 standard to avoid warnings)
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        # Restored from your original zshrc flow
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/main.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/main.zsh"
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/programs.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/programs.zsh"

        # Initialize Oh My Posh — must live here since NixOS has no Debian .zshrc
        eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-bubbles.yaml)"

        # Powerlevel10k (Backup/Manual if needed)
        [[ -f "${config.home.homeDirectory}/.p10k.zsh" ]] && source "${config.home.homeDirectory}/.p10k.zsh"
      '')

      # 2. LATE OVERRIDES (Ensure these run AFTER Oh My Zsh and its plugins)
      (lib.mkOrder 2000 ''
        # Re-enable fzf-tab after compinit (plugins can be sourced before compinit,
        # causing Tab to be rebound by the completion init — this restores it)
        enable-fzf-tab 2>/dev/null || true

        # Source custom functions LAST so our 'cd' wins over any plugin
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/functions.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/functions.zsh"
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/extras.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/extras.zsh"

        # Source aliases (including overrides)
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/aliases.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/aliases.zsh"
        
        # Restore the openSUSE hack: '..' is normal
        alias ..="builtin cd .."
      '')
    ];
  };
}
