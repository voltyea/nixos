{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./users/volty.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.kernelModules = ["rtw89"];
  boot.kernelParams = ["iomem=relaxed"];
  hardware.enableAllFirmware = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "xhci_hcd"
    "ehci_pci"
    "ehci_hcd"
    "ohci_hcd"
    "uhci_hcd"
    "usbcore"
    "usb_common"
    "usb_storage"
    "uas"
    "scsi_mod"
    "sd_mod"
    "sr_mod"
    "ahci"
    "libahci"
    "libata"
    "usbhid"
    "hid_generic"
    "nvme"
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kolkata";

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "start-hyprland";
        user = "volty";
      };
      default_session = initial_session;
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.fish;
  programs.firefox.enable = true;
  qt.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.hyprland.enable = true;
  programs.neovim.enable = true;
  hardware.intel-gpu-tools.enable = true;
  programs.git.enable = true;
  programs.flashrom.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.EDITOR = "nvim";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kitty
    brightnessctl
    adwaita-icon-theme
    nautilus
    whitesur-gtk-theme
    whitesur-icon-theme
    bibata-cursors
    tree
    clang
    unzip
    matugen
    cliphist
    grimblast
    jq
    wf-recorder
    slurp
    mpv
    pulseaudioFull
    pavucontrol
    cava
    entr
    hyprpicker
    libnotify
    starship
    hyprpolkitagent
    cmake
    gnumake
    ninja
    wirelesstools
    spotify
    glslviewer
    nwg-look
    alejandra
    qt6.qtimageformats
    (qt6.callPackage ./pkgs/luna/moon/moon.nix {})
    (qt6.callPackage ./pkgs/luna/network/network.nix {})
    (callPackage ./pkgs/luna/luna.nix {})
    dmidecode
    p7zip
    file
    gparted
    kdePackages.dolphin
    innoextract
  ];

  fonts.packages = with pkgs; [
    adwaita-fonts
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    (callPackage ./pkgs/fonts/sf-pro/sf-pro-rounded-medium.nix {})
    (callPackage ./pkgs/fonts/ligasf/ligasfmononerdfont-medium.nix {})
    (callPackage ./pkgs/fonts/icomoon/icomoon.nix {})
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.gvfs.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      JustWorksRepairing = "always";
    };
  };

  system.stateVersion = "25.05";
}
