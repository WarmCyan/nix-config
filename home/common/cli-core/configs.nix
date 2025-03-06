{ pkgs, self, gitUsername, gitEmail, ... }:

let
  inherit (builtins) readFile;
  inherit (self.mylib) concatFiles;
in
{
  programs.git = {
    enable = true;
    userName = gitUsername;
    userEmail = gitEmail;
    extraConfig = {
      init = { defaultBranch = "main"; }; # seems to be the new standard
      core = { pager = "cat"; }; # less pager is annoying since output won't persist in console
      diff = { colorMoved = "zebra"; }; # differentiates edited code from code that was simply moved
      pull = { rebase = false; }; # default is to merge when pulling rather than rebase (potentially lose history and other's local branches will be out of whack)
      commit = { verbose = false; }; # show diff in commit editor (changed to
      # false, because for very large commits this is ridiculous. Note that you
      # can still get this in a commit with the `-v` flag) 
    };
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    aggressiveResize = true; # when multiple sessions on same pane, force smallest size
    shortcut = "a"; # ctrl-a much less finger twisty than ctrl-b
    terminal = "xterm-256color";
    keyMode = "vi";
    sensibleOnTop = false; # wasn't a huge fan of those settings
    extraConfig = readFile ./tmux.conf;
  };

  # -- Shells --
  # NOTE: remember shell-bash-conf.sh sources ~/.bashrc_local
  programs.bash = {
    enable = true;
    shellAliases = import ./shell-aliases.nix;
    initExtra = concatFiles [ ./shell-common.sh ./shell-bash-conf.sh ];
  };
  # NOTE: remember shell-zsh-conf.sh sources ~/.zshrc_local
  programs.zsh = {
    enable = true;
    shellAliases = import ./shell-aliases.nix;
    initExtra = concatFiles [ ./shell-common.sh ./shell-zsh-conf.sh ];
    envExtra = ''
      # trying to get down ohmyzsh start times 
      # https://blog.patshead.com/2011/04/improve-your-oh-my-zsh-startup-time-maybe.html
      skip_global_compinit=1
    '';
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "pip" ];
    };
  };
}
