# https://discourse.nixos.org/t/bootstrapping-stand-alone-home-manager-config-with-flakes/17087/3
# 
# initialize this with 
# nix run --no-write-lock-file github:nix-community/home-manager/ -- --flake ".#PROFILENAME" switch
# home-manager --flake ".#PROFILENAME" switch
#
# NOTE: the above didn't actually work for me, instead use initial post:
# nix build --no-write-lock-file home-manager
# ./result/bin/home-manager --flake ".#PROFILENAME" switch
#
# see also: https://nix-community.github.io/home-manager/index.html#sec-flakes-standalone
#
# it is necessary with kitty to export TERMINFO_DIRS=/usr/share/terminfo
#
# TODO: create an install script that can be curl'd
#
# TODO: create homemanager script that can list diffs between generations/show what's installed
#
# NOTE: to search vimplugins do:
# nix-env -f '<nixpkgs>' -qaP -A vimPlugins | grep "pluginname"
# 
# https://www.lucacambiaghi.com/nixpkgs/readme.html
# from above, might be able to not have to go through home-manager interface? (rebuilt flake and then /result/bin/activate?)
#
# https://www.reddit.com/r/NixOS/comments/v2xpjm/big_list_of_flakes_tutorials/
#
# https://dev.to/vonheikemen/neovim-lsp-setup-nvim-lspconfig-nvim-cmp-4k8e


# CONFIG COLLECTION 
# ----------------------------
# https://github.com/Gerschtli/nix-config
# https://github.com/Misterio77/nix-config
# https://github.com/malob/nixpkgs
# ----------------------------




{
	description = "HM Configs";

	inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
        #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
            url = "github:nix-community/home-manager/release-22.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = {self, nixpkgs, home-manager}@inputs: 
    let
        pkgs = import nixpkgs {
            config.allowUnfree = true; # https://github.com/nix-community/home-manager/issues/2954

            overlays = [
                (self: super: {
                    vimPlugins = super.vimPlugins // {
                        cmp-nvim-lsp-signature-help = super.vimUtils.buildVimPluginFrom2Nix {
                            pname = "cmp-nvim-lsp-signature-help";
                            version = "2022-06-08";
                            src = super.fetchFromGitHub {
                                owner = "hrsh7th";
                                repo = "cmp-nvim-lsp-signature-help";
                                rev = "8014f6d120f72fe0a135025c4d41e3fe41fd411b";
                                # to find sha256, goto github, and grab the URL for code -> download ZIP
                                # then enter it into 
                                # nix-prefetch-url --unpack [URL]
                                sha256 = "1k61aw9mp012h625jqrf311vnsm2rg27k08lxa4nv8kp6nk7il29";
                            };
                        };
                    };
                })
            ];
            
            # https://nixos.wiki/wiki/Overlays
            # this almost worked except that pip dependencies obviously didn't
            #overlays = [
            #    (self: super: {
            #        python39Packages = super.python39Packages // {
            #            python-language-server = super.python39Packages.python-lsp-server;
            #        };
            #    })
            #
            #    (self: super: rec {
            #        python39 = super.python39.override {
            #            packageOverrides = self: super: {
            #                python-language-server = super.python-lsp-server;
            #            };
            #        };
            #        python39Packages = python39.pkgs;
            #    })
            #];
        };
    in
    {
        # TODO: for let stuff and possibly patching/fixing pkgs, see https://github.com/nix-community/home-manager/issues/2954

	
		# the default is a script to bootstrap the installation of home manager. 
		# you can run this by running `nix shell .` and then `bootstrap PROFILENAME`
		defaultPackage.x86_64-linux = 
			with import nixpkgs { system = "x86_64-linux"; }; 
			stdenv.mkDerivation rec {
				name = "hm-bootstrap";

                # TODO: output a help script as well
				installPhase = ''
					mkdir -p $out/bin
					echo "#!${runtimeShell}" >> $out/bin/bootstrap
					echo "export TERMINFO_DIRS=/usr/share/terminfo" >> $out/bin/bootstrap
					echo "nix build --no-write-lock-file home-manager" >> $out/bin/bootstrap
			 		echo "./result/bin/home-manager --flake \".#\$1\" switch" >> $out/bin/bootstrap
					chmod +x $out/bin/bootstrap
				'';
			
				dontUnpack = true;
			};



		homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
			configuration = {pkgs, ...}: {
				targets.genericLinux.enable = true;
				programs.home-manager.enable = true;
			};
			system = "x86_64-linux";
			homeDirectory = "/home/dwl";
			username = "dwl";
			stateVersion = "22.05";
		};

		homeConfigurations.dwl-standard = home-manager.lib.homeManagerConfiguration {
			configuration = {pkgs, ...}: {
				targets.genericLinux.enable = true;
				programs.home-manager.enable = true;
				
				home.packages = [
                    pkgs.python39Packages.python-lsp-server
                    pkgs.python39Packages.pylsp-mypy 
                    pkgs.python39Packages.pyls-isort
                    pkgs.python39Packages.python-lsp-black
                    pkgs.python39Packages.flake8

                    # NOTE: python-language-server and company are kind of broken
                    # https://github.com/NixOS/nixpkgs/issues/151659
				];
				
                programs.bash = {
					enable = true;
					shellAliases = import ./shell-aliases.nix;
                };
				programs.neovim = {
					enable = true;

                    extraConfig = builtins.readFile ./vimconf.vim;
					
					plugins = with pkgs.vimPlugins; [
						vim-nix
                        vim-monokai
                        nvim-lspconfig
                        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)) # unclear how to tell if this is working
                        { 
                            plugin = lightline-vim;
                            config = builtins.readFile ./vimlightline.vim;
                        }
					];

                    extraPython3Packages = (ps: with ps; [
                      jedi
                      pynvim
                    ]);
				};
			};
			system = "x86_64-linux";
			homeDirectory = "/home/dwl";
			username = "dwl";
			stateVersion = "22.05";
		};
	
		homeConfigurations.arcane = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
			configuration = {pkgs, ...}: {

                #nixpkgs.config.allowUnfree = true; # why doesn't this work?
                # https://github.com/NixOS/nixpkgs/issues/171810

                home.file.".mambarc".text = ''
channels:
    - conda-forge
                '';
                
                #let
                #    pkgs.python39Packages.python-language-server = pkgs.python39.python-lsp-server;
                #in # gah why does this not work
                # TODO: how can I modularize the tsserver stuff if I don't want in all configs?
                # I think instead of putting extras in extraPython3Packages, just put them in extraPackages.
                # basically how can I import a string from file and parameterize it?
				home.packages = [
					pkgs.cowsay
                    pkgs.ripgrep
                    pkgs.bat
                    pkgs.pre-commit
                    pkgs.micromamba
                    pkgs.zotero
                    
                    #pkgs.nodePackages.vue-language-server
                    #pkgs.nodePackages.bash-language-server
                    #pkgs.nodePackages.typescript
                    #pkgs.nodePackages.typescript-language-server
                    # pkgs.nodePackages.javascript-typescript-langserver # no longer maintained

                    # NOTE: python-language-server and company are kind of broken
                    # https://github.com/NixOS/nixpkgs/issues/151659
				];
				
				targets.genericLinux.enable = true;
				programs.home-manager.enable = true;
                programs.bash = {
					enable = true;
					shellAliases = import ./shell-aliases.nix;
                    
                    bashrcExtra = ''
                        # >>> mamba initialize >>>
                        export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
                        export MAMBA_ROOT_PREFIX='/home/81n/micromamba';
                        __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell bash --prefix '/home/81n/micromamba' 2> /dev/null)"
                        if [ $? -eq 0 ]; then 
                            eval "$__mamba_setup"
                        else
                            if [ -f "/home/81n/micromamba/etc/profile.d/micromamba.sh" ]; then
                                . "/home/81n/micromamba/etc/profile.d/micromamba.sh"
                            else
                                export  PATH="/home/81n/micromamba/bin:$PATH"
                            fi
                        fi
                        unset __mamba_setup
                        # <<< mamba initialize <<<
                        '';
                };
				programs.zsh = {
					enable = true;
					shellAliases = import ./shell-aliases.nix;
                    enableAutosuggestions = true;
                    oh-my-zsh = {
                        enable = true;
                        theme = "agnoster";
                        plugins = [
                            "git"
                            "pip"
                        ];
                    };
                    initExtra = builtins.concatStringsSep "\n" [
                      ''
                        # >>> mamba initialize >>>
                        export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
                        export MAMBA_ROOT_PREFIX='/home/81n/micromamba';
                        __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell zsh --prefix '/home/81n/micromamba' 2> /dev/null)"
                        if [ $? -eq 0 ]; then 
                            eval "$__mamba_setup"
                        else
                            if [ -f "/home/81n/micromamba/etc/profile.d/micromamba.sh" ]; then
                                . "/home/81n/micromamba/etc/profile.d/micromamba.sh"
                            else
                                export  PATH="/home/81n/micromamba/bin:$PATH"
                            fi
                        fi
                        unset __mamba_setup
                        # <<< mamba initialize <<<
                      ''
                      (builtins.readFile  ./additionalzshconfig.sh)
                    ];
				};
				programs.git = {
					enable = true;
					userName = "Martindale, Nathan";
					userEmail = "martindalena@ornl.gov";
                    extraConfig = { core = { pager = "cat"; }; };
				};
				programs.tmux = {
					enable = true;
					shell = "${pkgs.zsh}/bin/zsh";
					aggressiveResize = true;
					shortcut = "a";
                    terminal = "xterm-256color";
                    keyMode = "vi";
                    sensibleOnTop = false;
                    # didn't seem to work
                    # plugins = with pkgs; [
                    #   tmuxPlugins.vim-tmux-navigator
                    # ];
                    extraConfig = ''

                        # more sane split keys
                        unbind '"'
                        unbind %
                        bind | split-window -h
                        bind - split-window -v

                        bind C new-window -c '#{pane_current_path}'

                        # resize panes like vim
                        bind < resize-pane -L 3
                        bind > resize-pane -R 3
                        bind + resize-pane -U 3

                        # accept mouse input from term emulator
                        set -g mouse on

                        set -g history-limit 10000
                        

                      # Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

# these don't seem to work, 
# bind-key -T copy-mode-vi 'C-h' select-pane -L
# bind-key -T copy-mode-vi 'C-j' select-pane -D
# bind-key -T copy-mode-vi 'C-k' select-pane -U
# bind-key -T copy-mode-vi 'C-l' select-pane -R
# bind-key -T copy-mode-vi 'C-\' select-pane -l

                      
                      set -as terminal-features ",xterm-256:RGB"
                    ''; # doesn't handle (truecolor? 256 color?) vim themes without this
                    
				};
				programs.neovim = {
					enable = true;
                    viAlias = true;
                    vimAlias = true;

                    extraConfig = builtins.readFile ./vimconf.vim;

                    # this is a working method for combining multiple files
                    #extraConfig = builtins.concatStringsSep "\n" [
                    #    (builtins.readFile ./vimconf.vim)
                    #    "lua <<EOF"
                    #    (builtins.readFile ./vimlua.lua)
                    #    "EOF"
                    #];
					
                    # to search:
                    # nix-env -f '<nixpkgs>' -qaP -A vimPlugins | grep "pluginname"
					plugins = with pkgs.vimPlugins; [
                        #vim-monokai
                        everforest
                        
						vim-nix
                        vim-vue

                        indent-blankline-nvim
                        nvim-comment
                        vim-tmux-navigator
                        lualine-nvim
                        nvim-web-devicons
                        
                        nvim-lspconfig
                        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
                        null-ls-nvim
                        
                        nvim-cmp
                        cmp-buffer
                        cmp-spell
                        cmp-treesitter
                        cmp-nvim-lsp
                        cmp-path
                        luasnip
                        cmp_luasnip
                        cmp-nvim-lsp-signature-help
                        # TODO: there's also a fuzzy-buffer and fuzzy-path that I don't see in nixpkgs, see
                        # https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources

                        #lualine-lsp-progress
                        
                        #nvim-lightline-lsp
                        #{ 
                        #    plugin = lightline-vim;
                        #    config = builtins.readFile ./vimlightline.vim;
                        #}
					];

                    extraPackages = with pkgs; [
                        pkgs.nodePackages.vue-language-server
                        pkgs.nodePackages.bash-language-server
                        pkgs.nodePackages.vim-language-server
                        
                        pkgs.python39Packages.python-lsp-server
                        pkgs.python39Packages.pylsp-mypy 
                        pkgs.python39Packages.pyls-isort
                        pkgs.python39Packages.python-lsp-black
                        pkgs.python39Packages.flake8

                        #pkgs.vim-vint # (can be used with null_ls.builtins.diagnostics.vint)
                        #pkgs.nodePackages.eslint
                        # I was never able to get this to work, infuriating. I just installed npm 
                        # and the requisite packages through OS pkg manager.
                        #pkgs.nodePackages.typescript
                        #pkgs.nodePackages.typescript-language-server
                    ];

                    extraPython3Packages = (ps: with ps; [
                      jedi
                      pynvim
                    
                      #pkgs.python39Packages.python-lsp-server # ...this doesn't work, but it does when in pkgs
                      #python-language-server
                      #pkgs.python38Packages.python-language-server
                      #pkgs.python39Packages.pyls-mypy
                      #pkgs.python39Packages.pyls-isort
                      #pkgs.python39Packages.pyls-black
                    ]);
				};

                #xdg.configFile."nvim/vimlua.lua".source = ./vimlua.lua;
			};
			system = "x86_64-linux";
			homeDirectory = "/home/81n";
			username = "81n";
			stateVersion = "22.05";
		};
		
		
		#homeConfigurations.quark = homeConfigurations.dwl-standard;
	};
}
