# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  # nixpkgs.overlays = [
  #   (import ./overlays/nvim_overlay.nix)
  # ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Setup the bootloader for LUKS
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            efiInstallAsRemovable = false;
      };
    };

    initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/a42d30ca-2d5f-4af0-9175-7601ef1c4098";
    kernelParams = ["intel_iommu=on" "iommu=pt"];
    kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
  };

  # Turn off requirement to put in password for sudo commands
  security.sudo.extraRules = [
    {
      users = ["jose"];
      commands = [
        # {
        #     command = "ALL";
        #     options = ["NOPASSWD"];
        # }
        {
            command = "/run/current-system/sw/bin/lsblk";
            options = ["NOPASSWD"];
        }
        {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = ["NOPASSWD"];
        }
      ];
    }
    ];

  networking.hostName = "jbstl"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver = {
  #   enable = true;
  #   displayManager.lightdm.enable = true;
  # };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "jose";
    defaultSession = "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  # services.getty.autologinUser = "jose";
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # Enable copy and pasting into VM 
  # services.spice-vdagentd.enable = true;
  
  # Enable virtualisation
 virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.OVMF.override {
        secureBoot = true;
        tpmSupport = true;
      }).fd];
    };
  };
};


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jose = {
    isNormalUser = true;
    description = "Jose";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker"];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.filelight
      fzf
      ripgrep
      yakuake
      pciutils
      usbutils
      logseq
      zotero
      nodejs_22
      jetbrains-mono
      vlc
      mixxx
      geckodriver
      chromedriver
      pass
      fd
      evcxr
      jupyter
      rustup
      rust-analyzer
      nix-index
      sqlitebrowser
      zoom-us
      # wayland clipboard
      wl-clipboard-rs
    ];
  };

  fonts.packages = with pkgs; [
    eb-garamond
    nerdfonts
  ];

  # Set the default shell to zsh
  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;

  programs.npm.enable = true;

  programs.starship.enable = true;

  programs.firefox.enable = true;

  programs.virt-manager.enable = true;

  services.hardware.bolt.enable = true;

  services.cron.enable = true;

  # temporary until logseq is updated
  nixpkgs.config.permittedInsecurePackages = [
                "electron-27.3.11"
              ];

  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };
  # programs.nix-ld = {
  #   enable = true;
  #   libraries = with pkgs; [
  #     stdenv.cc.cc.lib
  #   ];
  # };

  # services.jupyter.enable = true;

  # programs.gnupg.agent = {
  #     enable = true;
  #     enableSSHSupport = true;
  # };
  # services.pcscd.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
      # bolt
      # kdePackages.plasma-thunderbolt
      # neovim
      appimage-run
      unzip
      # Required for gpg
      # pinentry-gtk2
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = ["nix-command" "flakes"];

}
