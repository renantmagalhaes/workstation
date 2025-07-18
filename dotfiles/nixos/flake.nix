{
  description = "My NixOS System Flake (25.05)";

  inputs = {
    nixpkgs = {
      #url = "github:NixOS/nixpkgs/fc0ef7621938b5826a7f49d080327a164e5a3d5e";
      url = "github:NixOS/nixpkgs/unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "path:/home/rtm/GIT-REPOS/workstation/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }@inputs: {
    nixosConfigurations."nix-pve-test" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
        ./configuration.nix
      ];
    };
  };
}
