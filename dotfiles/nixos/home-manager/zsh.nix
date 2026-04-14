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
        file = "init.sh";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "enhancd";
          rev = "v2.2.1";
          sha256 = "0iqa9j09fwm6nj5rpip87x3hnvbbz9w9ajgm6wkrd5fls8fn8i5g";
        };
      }
    ];

    # Replicate your Tumbleweed loading order (Before plugins/CompInit)
    initExtraBeforeCompInit = ''
      # Source custom scripts from dotfiles
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/main.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/main.zsh"
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/programs.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/programs.zsh"
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/functions.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/functions.zsh"
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/extras.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/extras.zsh"
    '';

    # Final initialization (After plugins/CompInit)
    initContent = ''
      # ENHANCD CONFIGURATION (restored from your old script)
      export ENHANCD_DISABLE_HYPHEN=1

      # Initialize Oh My Posh (Primary Theme)
      eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"

      # Powerlevel10k (Backup/Manual if needed)
      [[ -f "${config.home.homeDirectory}/.p10k.zsh" ]] && source "${config.home.homeDirectory}/.p10k.zsh"

      # Source aliases LAST (exactly like in your original zshrc)
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/aliases.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/aliases.zsh"
    '';
  };
}
