{ pkgs, lib, ... }:
with builtins;
with lib.attrsets;
let
  aliases = {
    "p" = ((import ./scripts.nix) pkgs).calc;
    "s" = "systemctl";
    "j" = "journalctl";
    "ju" = "journalctl -u";
    "jfu" = "journalctl -fu";
    "ls" = "${pkgs.eza}/bin/eza --git";
    "ll" = "${pkgs.eza}/bin/eza --git";
    "lt" = "${pkgs.eza}/bin/eza --long --tree -L 3";
    "open" = "${pkgs.xdg-utils}/bin/xdg-open";
    "clip" = "${pkgs.wl-clipboard-rs}/wl-copy";

    "pull" = "${pkgs.git}/bin/git pull";
    "push" = "${pkgs.git}/bin/git push";
    "commit" = "${pkgs.git}/bin/git commit";
    "add" = "${pkgs.git}/bin/git add";
    "patch" = "${pkgs.git}/bin/git add -p";
    "amend" = "${pkgs.git}/bin/git commit --amend";
  };
  # extracting any compressed format
  extract = ''
    extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   ${pkgs.gnutar}/bin/tar xjf $1     ;;
        *.tar.zst)   ${pkgs.gnutar}/bin/tar --zstd xf $1     ;;
        *.tar.gz)    ${pkgs.gnutar}/bin/tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       ${pkgs.gnutar}/bin/tar xf $1      ;;
        *.tbz2)      ${pkgs.gnutar}/bin/tar xjf $1     ;;
        *.tgz)       ${pkgs.gnutar}/bin/tar xzf $1     ;;
        *.zip)       ${pkgs.unzip}/bin/unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *.tar.xz)    ${pkgs.gnutar}/bin/tar xJf $1     ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
    }
  '';
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
            source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
            export FZF_DEFAULT_COMMAND="${pkgs.ripgrep}/bin/rg --files --follow"
            source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
            source "${pkgs.fzf}/share/fzf/completion.zsh"
            eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
            eval "$(${pkgs.atuin}/bin/atuin init zsh)"
            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

            ${extract}

            ${foldl' (a: b: a + "\n" + b) ""
            (mapAttrsToList (name: value: ''alias ${name}="${value}"'') aliases)}

      function t() {
          cd "$(${pkgs.custom.t}/bin/t-rs $@ | tail -n 1)"
      }

      function temp() {
          t $@
      }

      function rs() {
          cd "$(${pkgs.custom.t}/bin/t-rs $@ | tail -n 1)"
          cargo init . --bin --name $(basename "$PWD")
          vim src/main.rs
      }

      # path
      path() {
          export PATH="$1:$PATH"
      }

      path "$HOME/.cargo/bin"
      path "$HOME/.local/bin"
      path "$HOME/Documents/scripts"
      path "$HOME/.local/share/JetBrains/Toolbox/scripts"
    '';
  };
}
