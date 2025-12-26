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
        link_dir() {
          src_dir="$1"
            dest_dir="$2"
            skip_name="$3"

            for src in "$src_dir"/*; do
              [ -e "$src" ] || continue

                name="''${src##*/}"
                  [ -n "$skip_name" ] && [ "$name" = "$skip_name" ] && continue

                  dest="$dest_dir/$name"

                    [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] && continue
                    [ -e "$dest" ] && mv "$dest" "$dest.bak"
                      ln -s "$src" "$dest"
                        done
        }

      link_dir "$HOME/dotfiles"        "$HOME"         "config"
        link_dir "$HOME/dotfiles/config" "$HOME/.config" ""
    '';
  };
}
