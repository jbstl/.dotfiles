{
  description = "Jose's main flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOs/nixpkgs/nixos-24.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, ... }:
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
	  ];
        };
      };
    };
  }
