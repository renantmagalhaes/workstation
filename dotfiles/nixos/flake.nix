{
  description = "My NixOS System Flake (25.11)";

  inputs = {
    nixpkgs = {
      #url = "github:NixOS/nixpkgs/fc0ef7621938b5826a7f49d080327a164e5a3d5e";
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "path:/home/rtm/.dotfiles";
      flake = false;
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, nix-flatpak, quickshell, hyprland, ... }@inputs: {
    nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        hyprland.nixosModules.default
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
        ./configuration.nix
      ];
    };
  };
}
