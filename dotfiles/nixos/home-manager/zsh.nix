{ config, pkgs, inputs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initContent = ''
      # Initialize Oh My Posh with our linked config file
      eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/omp/oh-my-posh-minimal.yaml)"
    '';
    initExtra = ''
      # Source all of our custom zsh scripts from the dotfiles *flake input*
      [[ -f "${inputs.dotfiles}/zsh/main.zsh" ]] && source "${inputs.dotfiles}/zsh/main.zsh"
      [[ -f "${inputs.dotfiles}/zsh/programs.zsh" ]] && source "${inputs.dotfiles}/zsh/programs.zsh"
      [[ -f "${inputs.dotfiles}/zsh/functions.zsh" ]] && source "${inputs.dotfiles}/zsh/functions.zsh"
      [[ -f "${inputs.dotfiles}/zsh/extras.zsh" ]] && source "${inputs.dotfiles}/zsh/extras.zsh"
      [[ -f "${inputs.dotfiles}/zsh/aliases.zsh" ]] && source "${inputs.dotfiles}/zsh/aliases.zsh"
    '';
  };
}
