{ pkgs, ... }: {
  home.stateVersion = "24.05";
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  imports = [
    ../../programs/nvim
    ../../programs/zsh
    ../../programs/kanata
    ../../programs/kitty
  ];

  # use the system-installed version of kitty on arch
  # something graphics related crashes otherwise
  programs.kitty.package = pkgs.stdenv.mkDerivation {
      name = "kitty";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        echo "#!/usr/bin/env bash\nexec /usr/bin/kitty" > $out/bin/kitty;
      '';
  };
}
