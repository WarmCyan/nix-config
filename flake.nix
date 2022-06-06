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

				programs.zsh = {
					enable = true;
					#let aliasesFile = import ./shell-aliases.nix {}; in
					#aliasesFile = import ./shell-aliases.nix;
					#shellAliases = ./shell-aliases.nix;
					shellAliases = ./shell-aliases.nix;
				};

				
			};
			system = "x86_64-linux";
			homeDirectory = "/home/dwl";
			username = "dwl";
			stateVersion = "22.05";
		};
	

		homeConfigurations.arcane = home-manager.lib.homeManagerConfiguration {
			configuration = {pkgs, ...}: {

				home.packages = [
					pkgs.cowsay
				];
				
				targets.genericLinux.enable = true;
				programs.home-manager.enable = true;
                programs.bash = {
					enable = true;
					shellAliases = import ./shell-aliases.nix;
                };
				programs.zsh = {
					enable = true;
					shellAliases = import ./shell-aliases.nix;
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

					extraConfig = builtins.readFile ./vimconf.vim;
					
					plugins = with pkgs.vimPlugins; [
						vim-nix
                        vim-monokai
                        nvim-lspconfig
                        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
                        { 
                            plugin = lightline-vim;
                            config = builtins.readFile ./vimlightline.vim;
                        }
					];

                    extraPython3Packages = (ps: with ps; [
                      jedi
                      pynvim
                      pkgs.python37Packages.python-language-server
                      pkgs.python37Packages.pyls-mypy
                      pkgs.python37Packages.pyls-isort
                      pkgs.python37Packages.pyls-black
                    ]);
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
