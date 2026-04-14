{ config, pkgs, ... }:

{
  # Define a user account.
  users.users.rtm = {
    isNormalUser = true;
    description = "rtm";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" "libvirt" "vboxusers" "games" ];
    shell = pkgs.zsh; # Set Zsh as the default shell for this user
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
