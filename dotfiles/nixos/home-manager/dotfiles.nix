# We also add `inputs` to the function arguments here
{ config, pkgs, inputs, ... }:

{
  home.file = {
    # Symlink the Oh My Posh theme from the dotfiles *flake input*
    ".config/omp/oh-my-posh-minimal.yaml" = {
      source = "${inputs.dotfiles}/zsh/omp/oh-my-posh-minimal.yaml";
    };
  };
}
