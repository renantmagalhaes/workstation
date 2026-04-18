{ config, pkgs, inputs, lib, ... }:

{
  programs.nix-index.enable = true;

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
        # command-not-found enabled since we added nix-index below
        "command-not-found"
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
        # Source fzf-tab HERE (after compinit) — loading it via programs.zsh.plugins
        # causes it to load before compinit, so the widget is never registered.
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh

        # Initialize zoxide (must run before functions.zsh so our custom cd wins)
        eval "$(zoxide init zsh)"

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
