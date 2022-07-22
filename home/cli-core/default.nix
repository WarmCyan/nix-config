# These are the core cli tools and configs that I _always_ want to have available.
# This is a module! You can tell by the imports!

# TODO: possible packages:
# comma - https://github.com/nix-community/comma (install and run program by prepending ',')
# ipfetch - https://github.com/trakBan/ipfetch (display info about ip loc, useful for checking server logs maybe?)
# amfora - https://github.com/makeworld-the-better-one/amfora (gemini terminal client)
# bombadillo - https://bombadillo.colorfield.space/ (gemini and gopher and other client)

{ pkgs, lib, ... }: 

let
    inherit (builtins) readFile;
    inherit (lib) concatFiles;
in
{
    # imports = []
    
    home.packages = with pkgs; [
        # -- Basic utils --
        tree      # list a directory tree recursively, looks nicer than ls in select situations
        ripgrep   # speedy grep written in rust
        fzf       # very effective fuzzy finder
        bat       # fancier cat
        rsync     # better file transfer than scp and cp

        # -- TUI tools --
        bottom    # a cool-looking system viewer in rust
        ncdu      # disk usage, useful for discovering where all your diskspace went
        w3m       # terminal web browser

        # -- Fun, the spice of life :) --
        figlet    # output cool big terminal text
        cowsay    # what does the cow say?
        sl        # no environment is complete without it
        lolcat    # tool to vomit rainbow colors for input text
        tty-clock # best terminal clock around
        neofetch  # gotta show off my distro
    ];
    
    programs.git = {
        enable = true;
        #userName  # TODO: these should get set from 
        #userEmail
        init = { defaultBranch = "main"; }; # seems to be the new standard
        core = { pager = "cat"; }; # less pager is annoying since output won't persist in console
        diff = { colorMoved = "zebra"; }; # differentiates edited code from code that was simply moved
        pull = { rebase = false; }; # default is to merge when pulling rather than rebase (potentially lose history and other's local branches will be out of whack)
        commit = { verbose = true; }; # show diff in commit editor
        color = { ui = "always"; };
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
        oh-my-zsh = {
            enable = true;
            theme = "agnoster";
            plugins = [ "git" "pip" ];
        };
    };
    
}
