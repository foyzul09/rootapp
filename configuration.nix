{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
    ];
  

   # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 1;
       cores = 2;
  auto-optimise-store = true;

    substituters = lib.mkForce [
      "https://mirror.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
# Enable zRAM (Compressed swap in memory)
zramSwap.enable = true;
zramSwap.memoryPercent = 50;

# Garbage collection (keeps the system lean)
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
  
  # Bootloader configuration
  boot.loader = {
  systemd-boot.enable = false;
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    efiInstallAsRemovable = false;  # Changed from false to true
    gfxmodeEfi = "1920x1080";
    theme = "/boot/grub/themes/Acheron";
   
   };
  };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;
   boot.initrd.kernelModules = [ "amdgpu" "ahci" ];
  networking.hostName = "frost";
  networking.networkmanager.enable = true;
  
  # Plymouth configuration with silent boot :cite[1]
  boot.plymouth = {
    enable = true;
    theme = "rings";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "rings" ];
      })
    ];
  };

  # Enable "Silent boot" :cite[1]
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
 boot.kernelParams = [ "quiet" "splash" "mitigations=off" "amd_pstate=active"];

  # Services
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.dbus.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  
  

  # Set your time zone.
  time.timeZone = "Asia/Dhaka";

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account.
  users.users.frost = {
    isNormalUser = true;
    description = "Frost";
    extraGroups = [ "wheel" "networkmanager" "libvirt" "kvm" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Programs
  programs.steam.enable = true;
  programs.zsh.enable = true;

# 1. Enable Waydroid
  virtualisation.waydroid.enable = true;

  # 2. Fix Internet Connectivity for Waydroid
  # This allows the Android container to talk to your PC's network
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

boot.kernelModules = [ "ashmem_linux" "binder_linux" ];
networking.nftables.enable = false;
networking.firewall.allowedUDPPorts = [ 53 67 ];

virtualisation.waydroid.package = pkgs.waydroid-nftables;


  # Enable the background daemon service
  # On newer NixOS versions (unstable/24.11+), a dedicated module exists:


  # If the service above is not found (older versions), use this systemd manual link:
  # systemd.packages = [ pkgs.cloudflare-warp ];
  # systemd.targets.multi-user.wants = [ "warp-svc.service" ];
  
 # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
  gitea
  
    alacritty
    btop
    bear
    brightnessctl
    blender
    brave
    kdePackages.qtmultimedia
    bibata-cursors
    cava
    cargo
    clippy
    clang-tools
    cmake
    cliphist
    clinfo
      qt6.qtmultimedia
     dmidecode
    nemo-fileroller
    eza
    evince
    eog
    ffmpeg
   grim
  slurp
  jq
  satty
  tesseract
  zbar

    fastfetch
    ffmpegthumbnailer
    firefox
    file-roller
    fzf
    gamescope
    gcc15
    git
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gimp
    gnome-text-editor
    gnumake
    gnome-boxes
    gpu-screen-recorder
    gtk3
    gtk4
    heroic
    inkscape
    jdk21
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    kitty
    krita
    libva-utils
    lutris-unwrapped
    lohit-fonts.bengali
    libreoffice-qt6-fresh
    libcs50
    loupe
    mako
    qt6.qt5compat
     mangohud
    material-symbols
    mate.mate-polkit
    matugen
    mesa
    meson
    mission-center
    mpv
    nemo
    ninja
    nodejs
    nodePackages.prettier
    noto-fonts
    noto-fonts-cjk-sans
    
    nwg-look
    telegram-desktop
    protonplus
    pavucontrol
    protontricks
    protonvpn-gui
    python3
    qbittorrent
    lzip
    psmisc
     waydroid

    jmc2obj
    pakku
    rustc
    rustfmt
    scarab
    starship
    sassc
    steam
    telegram-desktop
    tokyonight-gtk-theme
    unzip
    vulkan-loader
    vulkan-tools
    vesktop
    vscode
    wineWowPackages.stagingFull
    wl-clipboard
    winetricks
    xdg-desktop-portal-gtk
    xdg-user-dirs
    xwayland-satellite
    zed-editor
    zen-browser
    zsh
    zulu8
    
    
  

  ]++ [
          inputs.zen-browser-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
          inputs.silent-sddm.packages.${pkgs.stdenv.hostPlatform.system}.default
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
           quickshell
           inputs.self.packages.${pkgs.system}.default
  ];
  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.opencl # Enables Rusticl (OpenCL) support
    ];
  };
  # Fonts configuration

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      lohit-fonts.bengali
      noto-fonts
      noto-fonts-cjk-sans
    ];
    
    # Corrected: fontconfig options sit directly under fonts.fontconfig
    fontconfig = {
      enable = true;
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <dir>~/.local/share/fonts</dir>
        </fontconfig>
      '';

      defaultFonts = {
        serif = [ "Noto Serif" "Noto Serif Bengali" ];
        sansSerif = [ "Noto Sans" "Noto Sans Bengali" ];
        monospace = [ "Noto Sans Mono" ];
      };
    };
  };

  # Set up Nemo as the default file manager.
  xdg.mime.defaultApplications = {
    "inode/directory" = [ "nemo.desktop" ];
  };
  
xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
  };

  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This is crucial for Wayland screen sharing
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Cursor default
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata_Modern_Classic";
    XCURSOR_SIZE = "24";
    QML2_IMPORT_PATH = [ "/run/current-system/sw/lib/qt-6/qml" ];
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };

  # SDDM
  services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.theme = "silent";
  services.displayManager.sddm.theme = lib.mkForce "/etc/sddm/themes/silent";






# Virtualization support
virtualisation.libvirtd = {
  enable = true;
  onShutdown = "suspend"; # Saves RAM/CPU by not forcing hard kills
  qemu.runAsRoot = false;
};
programs.virt-manager.enable = true; # optional but useful GUI



  # System version
  system.stateVersion = "25.11";
  
  # Niri
  programs.niri = {
    enable = true;
  };
}

