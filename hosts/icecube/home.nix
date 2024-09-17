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

  home.sessionVariables.PATH = "$HOME/.nix-profile/bin:$PATH";

  home.packages = with pkgs; [
    atuin
  ];
}
