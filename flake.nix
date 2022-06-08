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


# CONFIG COLLECTION 
# ----------------------------
# https://github.com/Gerschtli/nix-config
# https://github.com/Misterio77/nix-config
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
                        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
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
                
                #let
                #    pkgs.python39Packages.python-language-server = pkgs.python39.python-lsp-server;
                #in # gah why does this not work
				home.packages = [
					pkgs.cowsay
                    pkgs.ripgrep
                    
                    pkgs.python39Packages.python-lsp-server
                    pkgs.python39Packages.pylsp-mypy 
                    pkgs.python39Packages.pyls-isort
                    pkgs.python39Packages.python-lsp-black
                    pkgs.python39Packages.flake8

                    # NOTE: python-language-server and company are kind of broken
                    # https://github.com/NixOS/nixpkgs/issues/151659
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

                    # this is a working method for combining multiple files
                    #extraConfig = builtins.concatStringsSep "\n" [
                    #    (builtins.readFile ./vimconf.vim)
                    #    "lua <<EOF"
                    #    (builtins.readFile ./vimlua.lua)
                    #    "EOF"
                    #];
					
					plugins = with pkgs.vimPlugins; [
						vim-nix
                        vim-monokai
                        nvim-lspconfig
                        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
                        { 
                            plugin = lightline-vim;
                            config = builtins.readFile ./vimlightline.vim;
                        }
						nvim-lightline-lsp
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
