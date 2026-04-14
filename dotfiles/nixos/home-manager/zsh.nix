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
        "git" "docker" "docker-compose" "fzf" "sudo" "extract" "ssh-agent"
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
      {
        name = "enhancd";
        file = "init.sh";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "enhancd";
          rev = "v2.5.1";
          sha256 = "1cljfw3ygg6s5nzl99wsj041pnjlby375vfjrpxv2z6jnnsaga4i";
        };
      }
    ];

    # 1. EARLY INITIALIZATION (NixOS 25.11 standard to avoid warnings)
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        # Restored from your original zshrc flow
        [[ -f "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/main.zsh" ]] && source "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/main.zsh"
        [[ -f "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/programs.zsh" ]] && source "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/programs.zsh"

        # Replicate your legendary openSUSE patches via environment variables:
        # 1. Remap enhancd triggers (Move interactive search off of ..)
        export ENHANCD_ARG_DOUBLE_DOT="."
        export ENHANCD_ARG_SINGLE_DOT=".."
        # 2. Replicate your second sed hack
        export ENHANCD_DISABLE_HYPHEN=1
        export ENHANCD_FILTER="fzf --height 50% --reverse --border --inline-info"

        # Initialize Oh My Posh (Primary Theme)
        eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"

        # Powerlevel10k (Backup/Manual if needed)
        [[ -f "${config.home.homeDirectory}/.p10k.zsh" ]] && source "${config.home.homeDirectory}/.p10k.zsh"
      '')

      # 2. LATE OVERRIDES (Ensure these run AFTER Oh My Zsh and its plugins)
      (lib.mkOrder 2000 ''
        # Source custom functions LAST so our 'cd .' wins over enhancd
        [[ -f "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/functions.zsh" ]] && source "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/functions.zsh"
        [[ -f "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/extras.zsh" ]] && source "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/extras.zsh"

        # Source aliases (including overrides)
        [[ -f "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/aliases.zsh" ]] && source "${config.home.homeDirectory}/GIT-REPOS/workstation/dotfiles/zsh/zsh-files/aliases.zsh"
        
        # Restore the openSUSE hack: '..' is normal
        alias ..="builtin cd .."
      '')
    ];
  };
}
