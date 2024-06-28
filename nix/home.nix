{config, pkgs, ...}:
let
  shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix";
      enc = "nvim ~/.dotfiles/nix/configuration.nix";
      evc = "nvim ~/.dotfiles/nvim/init.lua";
    };
in 
{
  home.username = "jose";
  home.homeDirectory = "/home/jose";

  # link nvim config files
  home.file.".config/nvim" = {
    source = ../nvim;
    recursive = true;
  };

  # link qemu config file
  home.file.".config/libvirt/qemu.conf" = {
    source = ../configs/qemu.conf;
    recursive = true;
  };

  home.packages = with pkgs; [
    #browsers
    chromium

    #office
    freeoffice
    thunderbird


    #utils
    tree
    unzip
    gparted
    bitwarden
    lazygit

    #c
    clang

    #rust
    cargo
    rust-analyzer
    
    #python
    python3

    #go
    go

    #communication
    discord
    slack
  ];

  programs.git = {
    enable = true;
    userName = "jbstl";
    userEmail = "jbstl@users.noreply.github.com";
  };

  programs.eza.enable = true;
  programs.btop.enable = true;
  programs.jq.enable = true;
  programs.lazygit.enable = true;
  programs.tmux.enable = true;
  programs.alacritty.enable = true;
  
  programs.gpg.enable = true;
  services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableScDaemon = false;
      pinentryPackage = pkgs.pinentry-gtk2;
    };

  programs.zsh = {
    enable = true;
    shellAliases = shellAliases;
  };
  services.ssh-agent.enable = true;

  # Determines the home manager release that the configuration is compatible
  # with. Helps avoid breakage when aney home manager release introduces
  # backwards incompatible changes.
  # 
  # You can update home manager without changing this value.
  home.stateVersion = "24.05";

  # Let home manager install and manage itself
  programs.home-manager.enable = true;



}
