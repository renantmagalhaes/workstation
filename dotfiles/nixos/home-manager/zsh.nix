{ config, pkgs, inputs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Loaded via zsh-defer below, after the first prompt is available.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

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
        # Shell utilities
        "fzf" "sudo" "extract" "ssh-agent"
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
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
    ];

    # 1. EARLY INITIALIZATION (NixOS 25.11 standard to avoid warnings)
    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        # Load zsh-defer before any startup work that may use it.
        source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
      '')

      (lib.mkOrder 550 ''
        # Restored from your original zshrc flow
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/main.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/main.zsh"
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/programs.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/programs.zsh"

        # Initialize Oh My Posh — must live here since NixOS has no Debian .zshrc
        eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"
      '')

      # 2. LATE OVERRIDES (Ensure these run AFTER Oh My Zsh and its plugins)
      (lib.mkOrder 2000 ''
        # Source fzf-tab HERE (after compinit) — loading it via programs.zsh.plugins
        # causes it to load before compinit, so the widget is never registered.
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh

        # Source custom functions LAST so our 'cd' wins over any plugin
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/functions.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/functions.zsh"
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/extras.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/extras.zsh"

        # Source aliases (including overrides)
        [[ -f "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/aliases.zsh" ]] && source "${config.home.homeDirectory}/.dotfiles/zsh/zsh-files/aliases.zsh"

        # zsh-defer's documented staged-loading pattern for interactive UI
        # plugins. Syntax highlighting stays last, as required by the plugin.
        zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        zsh-defer source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # zoxide is useful but non-critical for the first prompt. The short
        # idle delay keeps it behind the interactive plugins in the queue.
        if (( $+commands[zoxide] )); then
          zsh-defer -t 0.05 -c 'eval "$(zoxide init zsh)"'
        fi
        
        # Restore the openSUSE hack: '..' is normal
        alias ..="builtin cd .."
      '')
    ];
  };
}
