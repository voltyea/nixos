
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.kernelModules = [ "rtw89" ];
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
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

services.greetd = {
  enable = true;
  settings = rec {
    initial_session = {
      command = "${pkgs.hyprland}/bin/hyprland";
      user = "volty";
    };
    default_session = initial_session;
  };
};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.volty = {
    isNormalUser = true;
    description = "volty";
    home = "/home/volty/";
    extraGroups = [ "networkmanager" "wheel" ];
    #shell = pkgs.fish;
    packages = with pkgs; [
    ];

  };

  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.hyprland.enable = true;
  programs.neovim.enable = true;
  programs.git.enable = true;
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
  gcc
  unzip
  matugen
  cliphist
  grimblast
  jq
  quickshell
  wf-recorder
  linuxKernel.packages.linux_5_15.rtw89
  slurp
  mpv
  pulseaudioFull
  inkscape
  ];

fonts.packages = with pkgs; [
adwaita-fonts
nerd-fonts.symbols-only
noto-fonts
noto-fonts-cjk-sans
noto-fonts-emoji
(import ./pkgs/sf-pro-rounded-medium.nix { inherit pkgs; })
(import ./pkgs/ligasfmononerdfont-medium.nix { inherit pkgs; })
(import ./pkgs/icomoon.nix { inherit pkgs; })
];

nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.dconf.profiles.volty.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "WhiteSur-Dark";
        font-name = "SF Pro Rounded Medium 11";
	icon-theme = "WhiteSur-dark";
	cursor-theme = "Bibata-Modern-Ice";
	cursor-size = "24";
	font-hinting = "full";
	font-antialiasing = "rgba";
	font-rgba-order = "rgb";
	color-scheme = "prefer-dark";
	event-sounds = "true";
	nput-feedback-sounds = "false";
      };
    }
  ];

services.gvfs.enable = true;
hardware.bluetooth.enable = true;

system.userActivationScripts = {
    user = "volty";
    text = ''
TARGET_DIR="/home/volty/.config/"
FILES="/home/volty/dotfiles/hypr/
/home/volty/dotfiles/kitty/
/home/volty/dotfiles/nvim/
/home/volty/dotfiles/fish/
/home/volty/dotfiles/matugen/
/home/volty/dotfiles/quickshell/"

for SRC in $FILES; do
    BASENAME=$(basename "$SRC")
    DEST="$TARGET_DIR/$BASENAME"

        if [ -L "$DEST" ]; then
            LINK_TARGET=$(readlink "$DEST")
            if [ "$LINK_TARGET" == "$SRC" ]; then
                continue
            else
                mv -f "$DEST" "$DEST.bak"
            fi
        else
            mv -f "$DEST" "$DEST.bak"
        fi

    ln -sf "$SRC" "$DEST"
done

    '';
  };

  system.stateVersion = "25.05";

}
