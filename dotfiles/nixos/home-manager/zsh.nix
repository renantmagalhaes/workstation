{ config, pkgs, inputs, ... }:

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
        src = pkgs.zsh-enhancd;
      }
    ];

    # Final initialization
    initContent = ''
      # ENHANCD CONFIGURATION (restored from your old script)
      export ENHANCD_DISABLE_HYPHEN=1

      # Initialize Oh My Posh (Primary Theme)
      eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"

      # Powerlevel10k (Backup/Manual if needed)
      [[ -f "${config.home.homeDirectory}/.p10k.zsh" ]] && source "${config.home.homeDirectory}/.p10k.zsh"

      # Source custom scripts from dotfiles
      [[ -f "${inputs.dotfiles}/zsh/main.zsh" ]] && source "${inputs.dotfiles}/zsh/main.zsh"
      [[ -f "${inputs.dotfiles}/zsh/programs.zsh" ]] && source "${inputs.dotfiles}/zsh/programs.zsh"
      [[ -f "${inputs.dotfiles}/zsh/functions.zsh" ]] && source "${inputs.dotfiles}/zsh/functions.zsh"
      [[ -f "${inputs.dotfiles}/zsh/extras.zsh" ]] && source "${inputs.dotfiles}/zsh/extras.zsh"
      [[ -f "${inputs.dotfiles}/zsh/aliases.zsh" ]] && source "${inputs.dotfiles}/zsh/aliases.zsh"
    '';
  };
}
