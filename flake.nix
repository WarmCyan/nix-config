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
# TODO: see if there's a way to make a default package that's able to create a
# runnable to do the bootstrapping portion.


{
	description = "HM Configs";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-22.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {self, nixpkgs, home-manager}: {



		
		defaultPackage.x86_64-linux = 
			with import nixpkgs { system = "x86_64-linux"; }; 
			stdenv.mkDerivation rec {
				name = "hm-bootstrap";

				boostrapScript = ''
					#!${runtimeShell}
				'';
				#passAsFile = [ "bootstrapScript" ];
				installPhase = ''
					mkdir -p $out/bin
					echo "#!${runtimeShell}" >> $out/bin/bootstrap
					#echo "export TERMINFO_DIRS=/usr/share/terminfo" # TODO: unsure what exactly is needed for this
					echo "nix build --no-write-lock-file home-manager" >> $out/bin/bootstrap
			 		echo "./result/bin/home-manager --flake \".#\$1\" switch" >> $out/bin/bootstrap
					chmod +x $out/bin/bootstrap
				'';
				shellHook = ''
					echo "hello";
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



		
			# with import nixpkgs { system = "x86_64-linux"; }; 
			# # let 
			# # 	bootstrapScript = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "bootstrap" ''
			# # 		nix build --no-write-lock-file home-manager
			# # 		./result/bin/home-manager --flake ".#$1" switch
			# # 	'';
			# # in
			# stdenv.mkDerivation rec {
			# 	name = "hm-bootstrap";
			# 	dontUnpack = true;
			# 	#dontInstall = true;
			# 	#buildInputs = [ bootstrapScript ];
			# 	installPhase = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "bootstrap" ''
			# 		nix build --no-write-lock-file home-manager
			# 		./result/bin/home-manager --flake ".#$1" switch
			# 	'';

			# 	shellHook = ''
			# 		echo "Hello there!"
			# 	'';
			# };
		
		#self.packages.x86_64-linux.bootstrap-script;
			# with pkgs = import nixpkgs { system = "x86_64-linux"; };
			# let bootstrapScript = pkgs.writeShellScriptBin "bootstrap" ''
			# 	nix build --no-write-lock-file home-manager
			# 	./result/bin/home-manager --flake ".#$1" switch
			# '';
			# in
			# stdenv.mkDerivation rec {
			# 	name = "bootstrap-phase";
			# 	buildInputs = [ bootstrapScript ];
			# };

		#packages.x86_64-linux.bootstrap-script = 
	

		homeConfigurations.dwl-standard = home-manager.lib.homeManagerConfiguration {
		};
	

		homeConfigurations.arcane = home-manager.lib.homeManagerConfiguration {
			configuration = {pkgs, ...}: {

				home.packages = [
					pkgs.cowsay
					#pkgs.neovim
					#pkgs.tmux
					#pkgs.git
				];
				
				targets.genericLinux.enable = true;


				programs.home-manager.enable = true;
				programs.zsh = {
					enable = true;
					shellAliases = {

						# quick dir changes
						".." = "cd ..";
						"..." = "cd ...";
						"...." = "cd ....";

						# coloration
						ls = "ls --color=auto";
						grep = "grep --color=auto";
						ll = "ls -lAh --color=auto";

						# verbosity and human readable
						df = "df -h";
						du = "du -ch";
						cp = "cp -v";
						mv = "mv -v";

						# don't destroy my computer
						rm = "rm -Iv --preserve-root";
						chown = "chown --preserve-root";
						chmod = "chmod --preserve-root";
						chgrp = "chgrp --preserve-root";

						v = "nvim";
						c = "clear";
						q = "exit";
						mx = "chmod +x";
						lab = "cd ~/lab";

						# tmux
						tn = "tmux new-session -s";
						ta = "tmux attach -t";
						tl = "tmux ls";
						tk = "tmux kill-session -t";
						tc = "tmux new-session -t";

						# git
						g = "git status";
						ga = "git add -A";
						gc = "git commit -a";
						gu = "git push";
						gd = "git pull";
						gl = "git log --oneline -n 10";

					};
				};
				programs.git = {
					enable = true;
					userName = "Martindale, Nathan";
					userEmail = "martindalena@ornl.gov";
				};
				programs.tmux = {
					enable = true;
					shell = "${pkgs.zsh}/bin/zsh";
					aggressiveResize = true;
					shortcut = "a";
				};
				programs.neovim = {
					enable = true;

					extraConfig = ''

						if has('mouse')
							set mouse=a
							set mousehide " hide mouse when typing text
						endif

						" misc???
						syntax on
						filetype plugin indent on

                        colorscheme monokai

						" ==============================================================================
						" SETTINGS
						" ==============================================================================

						" look
						set number " line numbers!
						set scrolloff=4 " keep 4 visible lines around cursorline when near top or bottom
						set cursorline " bghighlight of current line
						set title " window title
						set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
						set laststatus=2 " always show status line
						set statusline=%t\ %m%*\ %y%h%r%w\ %<%F\ %*\ %=\ Lines:\ %L\ \ \ Col:\ %c\ \ \ [%n]
						set noshowmode " mode unnecessary since shown in lightline

						" search
						set hlsearch " highlight search matches
						set incsearch " move highlight as you add charachters to search string
						set ignorecase " ignore case in search
						set smartcase " ...unless being smart about it!

						" tabs
						set tabstop=4 " number of columns used for a tab
						set shiftwidth=4 " how columns indent operations (<<, >>) use
						set softtabstop=4 " how many spaces used when hit tab in insert mode
						set expandtab " I've given up the fight on spaces v tabs... :/


						" ==============================================================================
						" KEY BINDINGS
						" ==============================================================================

						" ESC to leave insert mode is terrible! 'jk' is much nicer
						inoremap jk <SPACE><BS><ESC>
						inoremap JK <SPACE><BS><ESC>
						inoremap Jk <SPACE><BS><ESC>

						" make ',' find next character, like ';' normally does
						nnoremap , ;

						" press ';' in normal mode instead of ':', it's too common to use shift all the time!
						nnoremap ; :
						vnoremap ; :

						" better window navigation
						noremap <C-h> <C-w>h
						noremap <C-j> <C-w>j
						noremap <C-k> <C-w>k
						noremap <C-l> <C-w>l
					'';
					
					plugins = with pkgs.vimPlugins; [
						vim-nix
                        vim-monokai
                        { 
                            plugin = lightline-vim;
                            config = ''let g:lightline = { 
                                \ 'colorscheme': 'powerline', 
                                \ 'active': {
                                    \ 'left': [ [ 'mode', 'paste' ],
                                              \ [ 'readonly', 'filename', 'modified'] ],
                                    \ 'right': [ [ 'lineinfo' ],
                                               \ [ 'percent', 'linecount' ],
                                               \ [ 'fileformat', 'fileencoding', 'filetype' ] ]'
                                \ },
                                \ 'component': {
                                    \ 'linecount': '%L'
                                \ },
                            \ }
                            '';
                        }
					];
				};
			};
			system = "x86_64-linux";
			homeDirectory = "/home/81n";
			username = "81n";
			stateVersion = "22.05";
		};
		
		
		#homeConfigurations.quark = homeConfigurations.dwl-standard;
	};

}
