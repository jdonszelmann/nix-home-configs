{ pkgs, ... }: {
  home.stateVersion = "24.05";
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
  imports = [ 
    ../../programs/gnome
    ../../programs/nvim
    ../../programs/zsh
  ];

  home.packages = with pkgs; [
    element-desktop
    atuin
    discord-canary
    comma
    (python3.withPackages (pip: with pip; [ numpy matplotlib ]))
    spotify
    firefox
    chromium
    syncthing
    nixfmt
    xdg-utils
    # to copy from the command line (my zsh config has an alias `clip` to pipe things to the clipboard)
    wl-clipboard-rs
    prismlauncher
    graphviz-nox

    inkscape
    gimp
    xournalpp
    libreoffice

    dogdns

    jetbrains.rust-rover

    vlc
    audacity
  ];

  programs.firefox = { enable = true; };

  services.syncthing = { enable = true; };

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      # merge.tool = "meld";
      # mergetool.meld.cmd = ''
      # ${pkgs.meld}/bin/meld "$LOCAL" "$BASE" "$REMOTE" --output "$MERGED"
      # '';
      push = { autoSetupRemote = true; };
    };
    aliases = { amend = "commit --amend"; };
    userName = "Jonathan Dönszelmann";
    userEmail = "jonathan@donsz.nl";
  };
}
