{
  description = "My NixOS System Flake (unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    grapeNutsFont = {
      url = "https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/GrapeNuts-Regular.ttf";
      flake = false;
    };
    icomoonFont = {
      url = "https://github.com/renantmagalhaes/workstation/raw/static-files/fonts/Icomoon-Feather.ttf";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, dotfiles, nix-flatpak, quickshell, ... }@inputs: {
    nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
        }
        ./configuration.nix
      ];
    };
  };
}
