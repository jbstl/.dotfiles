{
  description = "Jose's main flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOs/nixpkgs/nixos-24.05";
      # url = "github:NixOs/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, nix-ld, ... }:
    let 
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        jbstl = lib.nixosSystem {
          system = "x86_64-linux";
	  modules = [ ./configuration.nix 
            # make home-manager a module of nixos so that home-manager config
	    # will be deployed automatically
	    home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jose = import ./home.nix;
	     }

      nix-ld.nixosModules.nix-ld
      { programs.nix-ld.dev.enable = true; }


	  ];
        };
      };
    };
  }
