{ pkgs, ... }: {
  home.stateVersion = "24.05";
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  imports = [
    ../../programs/nvim
    ../../programs/zsh
    ../../programs/tmux
    ../../programs/git
  ];
}
