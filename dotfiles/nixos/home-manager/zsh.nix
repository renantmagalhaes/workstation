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
        src = pkgs.stdenv.mkDerivation {
          name = "enhancd-patched";
          src = pkgs.fetchFromGitHub {
            owner = "b4b4r07";
            repo = "enhancd";
            rev = "v2.5.1";
            sha256 = "1cljfw3ygg6s5nzl99wsj041pnjlby375vfjrpxv2z6jnnsaga4i";
          };
          installPhase = ''
            mkdir -p $out
            cp -r . $out
            # The legendary openSUSE hack: move interactive trigger from .. to .
            sed -i 's/\.\./\./g' $out/init.sh
          '';
        };
      }
    ];

    # 1. EARLY INITIALIZATION (NixOS 25.11 standard to avoid warnings)
    initContent = lib.mkOrder 550 ''
      # Restored from your original zshrc flow
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/main.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/main.zsh"
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/programs.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/programs.zsh"
    '';

    # 2. FINAL INITIALIZATION (Source functions/aliases AFTER plugins load)
    # Using initExtra for final customization ensures plugins load correctly in 25.11
    initExtra = ''
      export ENHANCD_DISABLE_HYPHEN=1
      export ENHANCD_FILTER="fzf --height 50% --reverse --border --inline-info"

      # Initialize Oh My Posh (Primary Theme)
      eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"

      # Powerlevel10k (Backup/Manual if needed)
      [[ -f "${config.home.homeDirectory}/.p10k.zsh" ]] && source "${config.home.homeDirectory}/.p10k.zsh"

      # Source custom functions LAST so our 'cd .' wins over enhancd
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/functions.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/functions.zsh"
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/extras.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/extras.zsh"

      # Source aliases (including overrides)
      [[ -f "${inputs.dotfiles}/zsh/zsh-files/aliases.zsh" ]] && source "${inputs.dotfiles}/zsh/zsh-files/aliases.zsh"
      
      # Restore the openSUSE hack: '..' is normal
      alias ..="builtin cd .."
    '';
  };
}
