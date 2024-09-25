_: {
  programs.git = {
    enable = true;
    userEmail = "jonathan@donsz.nl";
    userName = "Jonathan Dönszelmann";
    signing.key = "/home/jonathan/.ssh/id_ed25519.pub";
    signing.signByDefault = true;

    delta.enable = true;
    delta.options = {
      navigate = true;
      light = false;
    };

    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
      init.defaultBranch = "main";
      gpg.format = "ssh";
      diff.colorMoved = true;
      rerere.enabled = true;

    };
  };
}
