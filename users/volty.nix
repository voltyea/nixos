{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users.volty = {
    isNormalUser = true;
    description = "volty";
    home = "/home/volty/";
    extraGroups = ["networkmanager" "wheel" "input" "video"];
    packages = with pkgs; [
    ];
  };

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
system.userActivationScripts = {
  user = "volty";
  text = ''
    for src in "$HOME"/dotfiles/*; do
      [ -e "$src" ] || continue
      [ "$(basename "$src")" = "config" ] && continue
      name="''${src##*/}"
      dest="$HOME/$name"
      if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        continue
      fi
      [ -e "$dest" ] && mv "$dest" "$dest.bak"
      ln -s "$src" "$dest"
    done
    for src in "$HOME"/dotfiles/config/*; do
      [ -e "$src" ] || continue
      name="''${src##*/}"
      dest="$HOME/.config/$name"
      if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        continue
      fi
      [ -e "$dest" ] && mv "$dest" "$dest.bak"
      ln -s "$src" "$dest"
    done
  '';
};

  }
