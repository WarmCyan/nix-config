# DONE: create an "install" script
# DONE: output a README to the folder containing iris information
# STRT: inject iris information into comment at beginning of each file

# DONE: bin/td-state
# DONE: bin/add-jupyter-env
# DONE: bin/tools
# DONE: add link to main nix config in readme

# the IDEA: for this will be to create an "export folder" that's timestamped and
# has current git version info etc.

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "export-dots";
  version = "0.3.0";
  description = "Turn nix-ified configs and scripts into non-nix-ified versions, so they can be copied onto systems that are too hard to get nix onto.";
  usage = "export-dots [LOCATION]  # LOCATION by default is ~/dots";
  parameters = {};
  runtimeInputs = [ pkgs.shellcheck pkgs.shfmt ];
  text = /* bash */ ''

  export_folder="''${1-$HOME/dots}"
  mkdir -p "''${export_folder}"
  mkdir -p "''${export_folder}/home"
  mkdir -p "''${export_folder}/bin"
  
  hm_config=""
  hm_hash=""
  hm_revCount=""
  hm_lastMod=""

  VERSION=$(export-dots --version) # :D :D :D :D this is fine

  # attempt to get current iris system/config info
  if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
    if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname" ]]; then
      hm_config=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname")
    fi
    if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configShortRev" ]]; then
      hm_hash=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configShortRev")
    fi
    if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configRevCount" ]]; then
      hm_revCount=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configRevCount")
      if [[ "''${hm_revCount}" == "dirty" ]]; then
        hm_revCount=""
      fi
    fi
    if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configLastModified" ]]; then
      hm_lastMod=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configLastModified")
      if [[ "''${hm_lastMod}" != "dirty" ]]; then
        hm_lastMod=$(date -d "@''${hm_lastMod}" +"%Y-%m-%d")
      fi
    fi
  fi

  function export_bashrc {
    target_bashrc="''${export_folder}/home/.bashrc"
    echo "exporting ~/.bashrc to ''${target_bashrc}..."
    
    cp ~/.bashrc "''${target_bashrc}"
    chmod 777 "''${target_bashrc}"
    
    # fix micromamba nix paths
    #sed -i -E "s/(.*)\/nix\/store\/.*\/bin\/micromamba(.*)/\1\$HOME\/.local\/bin\/micromamba\2/g" "''${target_bashrc}"
    sed -i -E "s/export MAMBA_EXE=.*/export MAMBA_EXE=\$HOME\/.local\/bin\/micromamba/" "''${target_bashrc}"
    sed -i -E "s/export MAMBA_ROOT_PREFIX=.*/export MAMBA_ROOT_PREFIX=\$HOME\/micromamba/" "''${target_bashrc}"
    sed -i -E "s/__mamba_setup=.*/__mamba_setup=\"\$\(\$MAMBA_EXE shell hook --shell bash --prefix \$MAMBA_ROOT_PREFIX 2\> \/dev\/null\)\"/" "''${target_bashrc}"
    sed -i -E "s/\/home\/dwl\/micromamba/\$MAMBA_ROOT_PREFIX/g" "''${target_bashrc}"

    # remove bash_completion path
    # TODO: the original path looks to be /etc/profile.d/bash_completion.sh,
    # could prob just use that if it exists?
    # remove the line referencing that versinfo line
    sed -i "/.*BASH_COMPLETION_VERSINFO.*/d" "''${target_bashrc}"
    # remove the line with the profile.d/bash etc. and the line after it (,+1d)
    sed -i "/.*profile.d\/bash_completion.sh.*/,+1d" "''${target_bashrc}"
  }
  
  function export_tmux {
    target_tmuxconf="''${export_folder}/home/.tmux.conf"
    echo "exporting ~/.config/tmux/tmux.conf to ''${target_tmuxconf}..."

    cp ~/.config/tmux/tmux.conf "''${target_tmuxconf}"
    chmod 777 "''${target_tmuxconf}"

    # fix default shell line (TODO: for now just remove, make an option for zsh
    # later)
    sed -i "/.*default-shell.*/d" "''${target_tmuxconf}"
  }

  function export_vim {
    target_vimrc="''${export_folder}/home/.vimrc"
    echo "exporting vim configuration..."

    # copy over init.lua
    mkdir -p "''${export_folder}/home/.config/nvim"
    target_initlua="''${export_folder}/home/.config/nvim/init.lua"
    cp ~/.config/nvim/init.lua "''${target_initlua}"
      
    # get the source vimrc from the path inside init.lua, and copy it into .vimrc
    # replace the init.lua text with _only the exact path_
    sed -i -E "s/.*\[\[source\ (\/nix\/store\/.*\.vim)\]\]/\1/g" "''${target_initlua}"
    # read from that path into /home/.vimrc
    vimrc_path=$(cat "''${target_initlua}")
    echo -e "\texporting ''${vimrc_path} into ''${target_vimrc}..."
    cp "''${vimrc_path}" "''${target_vimrc}"
    chmod 777 "''${target_vimrc}"

    # remove lua plugins
    # delete everything below line LUA PLUGIN SETUP
    sed -i "/LUA PLUGIN SETUP/Q" "''${target_vimrc}"

    # remove colorscheme
    sed -i "/colorscheme everforest/d" "''${target_vimrc}"
    
    # change init.lua to init.vim and replace content with https://vi.stackexchange.com/questions/12794/how-to-share-config-between-vim-and-neovim
    target_initvim="''${export_folder}/home/.config/nvim/init.vim"
    echo -e "\treseting to a common ''${target_initvim}..."
    chmod 777 "''${target_initlua}"
    mv "''${target_initlua}" "''${target_initvim}"
    cat << EOF > "''${target_initvim}" 
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
EOF
  }
  
  function export_simple_fixed_tool {
    target_tool="''${export_folder}/bin/''${1}"
    echo "exporting tool ''${1}..."

    cp ~/.nix-profile/bin/"''${1}" "''${target_tool}"
    chmod 777 "''${target_tool}"
    chmod +x "''${target_tool}"

    # replace the shebang line
    sed -i "1s/.*/#!\/bin\/bash/" "''${target_tool}"

    # remove any export PATH stuff if it's within the first 40 lines
    sed -i "1,40{/export PATH=\".*\"/d}" "''${target_tool}"

    # add generation information
    generation_information="# This tool was initially generated from a nix configuration:\n# https://github.com/WildfireXIII/nix-config\n#\n# Config name: ''${hm_config}\n# Commit hash: ''${hm_hash} (v''${hm_revCount})\n# Config date: ''${hm_lastMod}\n# Exported with export-dots v''${VERSION}"
    if grep -q "# License: MIT" < "''${target_tool}"; then
      sed -i "/# License: MIT/a #\n''${generation_information}" "''${target_tool}"
    else
      sed -i "2i ''${generation_information}\n" "''${target_tool}"
    fi

    shellcheck "''${target_tool}"
    shfmt --indent 2 --case-indent --write "''${target_tool}"
  }

  function write_installer {
    installer_path="''${export_folder}/install.sh"
    echo "Writing installer script to ''${installer_path}..."

    # TODO: this probably should just be in its own file?
    cat << EOF > "''${installer_path}"
#!/bin/bash

echo "Installing dots..."
set -o xtrace
cp home/.bashrc ~
cp home/.tmux.conf ~
cp home/.vimrc ~
mkdir -p ~/.config/nvim
cp home/.config/nvim/init.vim ~/.config/nvim
mkdir -p ~/bin
echo "export PATH=\"\$HOME/bin:\\\$PATH\"" >> ~/.bashrc
cp bin/* "\$HOME/bin"
set +o xtrace
EOF
    chmod +x "''${installer_path}"
  }

  function write_readme {
    readme="''${export_folder}/README.md"
    echo "Writing readme at ''${readme}..."

    {
      echo "# Dotfiles"
      echo ""
      echo "Alas, I find it too difficult to install nix on some systems...so this repo contains autogenerated/exported config and script files that have been scrubbed of nix paths so they still work."
      echo ""
      echo "The nix configuration that these are generated from can be found at:  "
      echo "[https://github.com/WildfireXIII/nix-config](https://github.com/WildfireXIII/nix-config)"
      echo ""
      echo "## Current dotfiles generation information"
      echo ""
      echo "Config name: ''${hm_config}  "
      echo "Commit hash: ''${hm_hash} (v''${hm_revCount})  "
      echo "Config date: ''${hm_lastMod}  "
      echo "Exported with export-dots v''${VERSION}  "
      echo ""
      echo "## Usage"
      echo ""
      echo '```'
      echo './install.sh'
      echo '```'
    } > "''${readme}"
  }

  function write_license {
    license="''${export_folder}/LICENSE.txt"
    echo "Writing license at ''${license}..."
    cat << EOF > "''${license}"
Copyright (c) 2023 Nathan Martindale

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
  }
  

  export_bashrc
  export_tmux
  export_vim
  export_simple_fixed_tool "tools"
  export_simple_fixed_tool "td-state"
  export_simple_fixed_tool "add-jupyter-env"
  export_simple_fixed_tool "sri-hash"
  write_installer
  write_readme
  '';
}
