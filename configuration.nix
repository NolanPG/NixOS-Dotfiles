{ 
  config, 
  lib, 
  pkgs, 
  ... 
}:

{
  imports =
    [
      ./hardware-configuration.nix
      ./gaming.nix
      ./network.nix
      ./vfio.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    # Setting latest stable Linux Kernel from nixpkgs
    kernelPackages = pkgs.linuxPackages_latest;

    # Enabling ntfs support
    supportedFilesystems = [ "ntfs" ];

    loader = {
      # Using grub as bootloader
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  # Enabling SOUND
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Uncomment this to use JACK applications
    # jack.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalization properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Plasma 6 as the DE, for the time being it is only available in NixOS Unstable
  services.desktopManager.plasma6.enable = true;

  # Enabling Xorg even though I use Wayland because some Xorg apps had troubles with XWayland support (Not sure about that)
  services.xserver.enable = true;
  programs.xwayland.enable = true;

  # Stating system's gpu driver, not needed in some cases
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Plasma Wayland as default
  services.displayManager.defaultSession = "plasma";

  # Enabling dconf as a dependency of Firefox for it to being ablo of getting magnets' mime type and launch Deluge as a torrent client properly
  programs.dconf.enable = true;

  # Setting sddm as the display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enabling XDG Portal to make GTK apps use the QT Portal when opening files or folders
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
    ];
    # Force GTK apps to use QT FM for opening folders
    # gtkUsePortal = true;
  };

  # Enabling Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    libsForQt5.kservice # kbuildsycoca5
    distrobox

    # Packages normally included in other distros by default
    lshw 
    wget

    qdirstat # App for managing disk space usage

    kdePackages.appstream-qt # libsForQt5 is replaced by kdePackages to keep coherence for Plasma 6 naming

    # peazip # Free Zip / Unzip software and Rar file extractor. Cross-platform file and archive manager.

    # Ark Extraction dependencies
    libarchive
    libzip
    p7zip
    unrar
    zlib
    unzip

    # System Settings info panel dependencies
    wayland-utils
    vulkan-tools
    glxinfo
    virtualgl
    clinfo

    # obs-studio dependencies
    pciutils
    rnnoise
    mesa
    fdk-aac-encoder
    rav1e

    # Firefox dependencies
    ffmpeg_7-full
    mailcap # Helper application and MIME type associations for file types

    # Overriding vscode with vscodium package to manage its extensions declaratively
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        ms-python.vscode-pylance
        catppuccin.catppuccin-vsc
        pkief.material-product-icons

        #CPP
        ms-vscode.cpptools
        adpyke.codesnap
        oderwat.indent-rainbow

        #RUST
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
      ];
    })

    # Apps for VFIO
    looking-glass-client
    virt-manager

  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    vfio.enable = true;
  };


  environment.variables = {
    # Force GTK apps to use QT Portal for opening folders or files (same as gtkUsePortal = true; but that's deprecated)
    GTK_USE_PORTAL = "1";
  };

  # Enabling flatpak support, still have to run:
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  # For adding flathub to flatpak
  # TODO there's a project https://github.com/gmodena/nix-flatpak that helps with making flatpak management declaratively I'll look into that
  services.flatpak.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enabling Docker virtualization
  virtualisation.docker.enable = true;

  # Setting up fonts
  fonts = {
    packages = with pkgs; [
      ibm-plex # GUI font
      meslo-lgs-nf # Konsole font
    ];

    fontconfig.defaultFonts = {
      serif = [ "IBM Plex Sans" ];
      sansSerif = [ "IBM Plex Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs = {
      partition-manager.enable = true; # KDE Partition Manager

      # Setting up oh-my-zsh
      zsh = {
        enable = true;
        enableBashCompletion = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;

        # Setting PowerLevel10k as the zsh theme
        promptInit = "source ''${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

        ohMyZsh = {
          enable = true;
          plugins = [
            "sudo"
            "git"
          ];
        };
      };

      # Configuring FireFox
      firefox = {
        package = pkgs.firefox;
        enable = true;
        preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  # Aliases
  environment.shellAliases = {
    ll = "ls -l";
    ls = "ls --color=tty";
    nix-find = "nix --extra-experimental-features \"nix-command flakes\" search nixpkgs";
    neofetch = "fastfetch";
    config-nixos = "codium /home/nolan/.dotfiles";

    # switch-nixos rebuilds NixOS using system-wide configuration, then rebuilds home using home.nix and finally it refreshes KDE app cache (icons in app launcher)
    switch-nixos = "sudo nixos-rebuild switch --flake /home/nolan/.dotfiles && home-manager switch --flake /home/nolan/.dotfiles && kbuildsycoca5";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nolan.isNormalUser = true;
  users.users.nolan.extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older ` NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

