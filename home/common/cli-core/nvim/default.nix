# THE ALL IMPORTANT AND MIGHTY NEOVIM CONFIGURATION STUFFS.
# TODO: at some point possibly move the lsp stuff out to dev?
# unclear if I want to break up nvim configuration into two separate sections,
# but it might make it cleaner here.
# NOTE: that this is what misterio does, though it's just broken up into diff
# files in the same folder, not completely separate directories.

# TODO: keep vim config separate, and minimal, (and don't set vimAlias) so if
# you want simple/raw editing capability can just use vim instead of neovim.

# TODO: do more space bindings in normal, e.g. recommended for format is
# <space>f, and misterio mapped <space>m to make for example.

# TODO: use relativenumber line numbers ("set number relativenumber")

# TODO: possible plugins:
# vim-illuminate - https://github.com/RRethy/vim-illuminate (highlight other instances of that var/word)
# which-key - https://github.com/folke/which-key.nvim (popup with possible keybindings from what you started typing, useful for remembering posible commands)
# nvim-tree - https://github.com/kyazdani42/nvim-tree.lua (better nerdtree)
# telescope - https://github.com/nvim-telescope/telescope.nvim (consider over vista?)
# trouble - https://github.com/folke/trouble.nvim (nice list of diagnostics errors, better than default)
# medieval - https://github.com/gpanders/vim-medieval (execute code blocks in markdown files)

{ pkgs, ... }:
let
  inherit (builtins) readFile;
in
{

  # home.file.".snippets/package.json".text = readFile ./snippets/package.json;
  # home.file.".snippets/json.json".text = readFile ./snippets/json.json;
  # home.file.".snippets/python.json".text = readFile ./snippets/python.json;
  # home.file.".snippets/svelte.json".text = readFile ./snippets/svelte.json;

  home.file.".config/nvim/queries/comment/highlights.scm".text = ''
    ;; extends
    ((tag
      (name) @TODO_todo @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @TODO_todo "TODO"))

    ((tag
      (name) @TODO_strt @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @TODO_strt "STRT"))

    ((tag
      (name) @TODO_wait @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @TODO_wait "WAIT"))

    ((tag
      (name) @TODO_done @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @TODO_done "DONE"))

    ((tag
      (name) @TODO_canc @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @TODO_canc "CANC"))

    ((tag
      (name) @NOTES_bug @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @NOTES_bug "BUG"))

    ((tag
      (name) @NOTES_fixd @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @NOTES_fixd "FIXD"))

    ((tag
      (name) @NOTES_idea @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @NOTES_idea "IDEA"))

    ((tag
      (name) @NOTES_note @nospell
        ((user) @constant)?
      ":" @punctuation.delimiter)
      (#any-of? @NOTES_note "NOTE"))

    ; ((tag
    ;   (name) @TODO_strt @nospell
    ;   ("(" @punctuation.bracket
    ;     (user) @constant
    ;     ")" @punctuation.bracket)?
    ;   ":" @punctuation.delimiter)
    ;   (#any-of? @TODO_strt "STRT"))
  '';

  # always have a fallback "vanilla" vim (still uses my non-plugin based conf)
  programs.vim = {
    enable = true;
    extraConfig = readFile ./vim-conf.vim;
    plugins = with pkgs.vimPlugins; [
      everforest
    ];
  };

  programs.nixvim = {
    enable = true;
    vimAlias = false;

    keymaps = [
      {
        mode = "n";
        key = "<LEADER>e";
        action = ":NvimTreeToggle<cr>";
        options = {
          silent = true;
          noremap = true;
        };
      }
      {
        mode = "n";
        key = "//";
        action = ":FzfLua lsp_document_symbols<cr>";
        options = {
          silent = true;
          noremap = true;
        };
      }
      {
        mode = "n";
        key = "<LEADER>t";
        action = ":Neotest summary<CR>";
        options = {
          silent = true;
          noremap = true;
        };
      }
      # { mode = ["n" "v"]; key="ga"; action="<cmd>lua require('actions-preview').code_actions<cr>"; }
    ];

    # lsp = {
    #   keymaps = [
    #     { key = "<C-f>"; lspBufAction = "format"; }
    #     { key = "gd"; lspBufAction = "definition"; }
    #     { key = "gi"; lspBufAction = "implementation"; }
    #     { key = "gr"; lspBufAction = "references"; }
    #     { key = "K"; lspBufAction = "hover"; }
    #     { key = "<leader>lx"; action = "<CMD>LspStop<Enter>"; }
    #     { key = "<leader>ls"; action = "<CMD>LspStart<Enter>"; }
    #     { key = "<leader>lr"; action = "<CMD>LspRestart<Enter>"; }
    #   ];
    #   servers = {
    #     autotools_ls.enable = true; # makefiles
    #     bashls.enable = true; # bash
    #     clangd.enable = true; # c/c++
    #     html.enable = true;
    #     nixd.enable = true; # nix
    #     # ruff.enable = true; # python
    #     ts_ls.enable = true; # typescript/javascript
    #     vimls.enable = true; # vim!
    #
    #     pylsp = {
    #       enable = true;
    #       config = {
    #         plugins = {
    #           pylint = { enabled = true; };
    #           ruff = { enabled = true; formatEnabled = true; };
    #         };
    #       };
    #     };
    #   };
    # };
    #
    plugins = {
      # ==============================
      # LINTERS/LSP/LANG STUFF
      # ==============================
      nix.enable = true;

      lspkind.enable = true; # add pictograms to LSP completion items
      lsp = {
        enable = true;
        keymaps.lspBuf = {
          "<C-f>" = "format";
          "gd" = "definition";
          "gi" = "implementation";
          "gr" = "references";
          "K" = "hover";
        };
        keymaps.extra = [
          {
            key = "<leader>lx";
            action = "<CMD>LspStop<Enter>";
          }
          {
            key = "<leader>ls";
            action = "<CMD>LspStart<Enter>";
          }
          {
            key = "<leader>lr";
            action = "<CMD>LspRestart<Enter>";
          }
        ];
        servers = {
          autotools_ls.enable = true; # makefiles
          bashls.enable = true; # bash
          clangd.enable = true; # c/c++
          html.enable = true;
          nixd.enable = true; # nix
          # ruff.enable = true; # python (diagnostics, code actions, and formatting)
          # pyright.enable = true; # (static typechecking, hopefully navigation and autocomplete?
          pyright = {
            enable = true;
            settings = {
              python = {
                analysis = {
                    diagnosticMode = "off";
                    typeCheckingMode = "off";
                };
              };
            };
          };
          ts_ls.enable = true; # typescript/javascript
          vimls.enable = true; # vim!

          # pylsp = {
          #   enable = true;
          #   settings = {
          #     plugins = {
          #       black.enabled = true;
          #       ruff.enabled = true;
          #       pylint.enabled = true;
          #     };
          #   };
          #   # config = {
          #   #   plugins = {
          #   #     pylint = { enabled = true; };
          #   #     ruff = { enabled = true; formatEnabled = true; };
          #   #   };
          #   # };
          # };
        };
      };

      # for code actions suggested by lsp's show previews and allow running
      # actions-preview = {
      #   enable = true;
      #   # settings = {
      #   # };
      # };
      # mini-pick.enable = true;  # (used by actions-preview, alternatives exist)

      # the null-ls successor, lsp server wrapper for any cli utils that don't have dedicated server
      # none-ls = {
      #   enable = true;
      #   # sources.diagnostics = {
      #   #   pylint.enable = true;
      #   # };
      #   sources.formatting = {
      #     black.enable = true;
      #     isort.enable = true;
      #     # nix_flake_fmt vs nixfmt vs nixpkgs_fmt??
      #   };
      #   settings = {
      #     diagnostics_format = "[#{c}] #{m} (#{s})";
      #     # debug = true;
      #     # on_attach = /* lua */ ''
      #     #   function(client, bufnr)
      #     #     -- Integrate lsp-format with none-ls
      #     #     require('lsp-format').on_attach(client, bufnr)
      #     #   end
      #     # '';
      #   };
      # };
      #
      #
      # lspconfig.enable = true;
      # lint.enable = true; # async linter spawner
      # nvim-lspconfig
      # lsp = {
      #   enable = true;
      # }

      # noegen.enable = true;  # TODO: auto create docstring syntax

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "treesitter"; }
            { name = "luasnip"; }
            { name = "nvim_lsp_signature_help"; }
          ];
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" =
              "cmp.mapping(function(fallback)
                  if cmp.visible() then
                      cmp.select_next_item()
                  elseif require('luasnip').expand_or_jumpable() then
                      require('luasnip').expand_or_jump()
                  else
                      fallback()
                  end
              end, { 'i', 's' })";
            "<S-Tab>" =
              "cmp.mapping(function(fallback)
                  if cmp.visible() then
                      cmp.select_prev_item()
                  elseif require('luasnip').jumpable(-1) then
                      require('luasnip').jump(-1)
                  else
                      fallback()
                  end
              end, { 'i', 's' })";
          };
        };
      };

      # ==============================
      # UTILS
      # ==============================

      # snippet engine, using snippets saved into ~/.snippets at the top
      luasnip = {
        enable = true;
        fromVscode = [
          { }
          {
            paths = [
              ./snippets
              "~/.snippets"
            ];
          }
        ];
        # settings.ext_opts = {
        #   "types.insertNode" = {
        #     active = {
        #   };
        # };
      };

      nvim-surround.enable = true; # make it easier to change quotes/braces around a thing etc.
      tmux-navigator.enable = true;

      # better highlighting, indentation etc.
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          highlight.disable = [ "vim" ];
          indent.enable = true;
        };
      };

      # treesj.enable? # more "correct" join/split for code blocks/arrays?

      # venv-selector.enable = true; # allow activating python environments from within nvim
      # venv-selector.settings.options.log_level = "DEBUG";
      # venv-selector.settings.options.debug = true;
      # venv-selector.settings.search.micromamba.command = "fd '/bin/python$' \"$HOME/micromamba/envs\" --no-ignore-vcs --full-path";

      vim-slime.enable = true; # allow sending snippets of text to nearby terminals/repls
      vim-slime.settings.target = "neovim";

      # ==============================
      # TESTING/DEBUGGING
      # ==============================

      # interact with tests within neovim
      neotest = {
        enable = true;
        adapters = {
          python.enable = true;
        };
      };
      # allow debugging tests
      dap.enable = true;
      dap-python.enable = true;
      # dap-ui.enable = true;
      # dap-virtual-text.enable = true;
      # dap-view.enable = true;

      # ==============================
      # INTERFACE
      # ==============================

      # trouble.anble = true? # TODO: possible replacement for previous \r to
      # find references etc?

      # navbuddy.enable = true;  # TODO: neat little vista replacement?
      # navic.enable = true; # TODO: better/more efficient version of context-nvim?

      # molten.enable = true; # ability to get jupyter-like notebook with image
      # rendering etc. to work

      # explore these more when get serious about using vim for obsidian
      # image.enable = true; # render images in markdown files
      # img-clip.enable = true; # make it easier to add images (e.g. from clipboard)
      # obsidian.enable = true; # !!!

      # show indentation guides and current scope
      hlchunk = {
        enable = true;
        settings = {
          # chunk = {
          #   enable = true;
          #   use_treesitter = false;
          # };
          indent = {
            enable = true;
            use_treesitter = false;
          };
        };
      };
      # indent-blankline = {
      #   enable = true;
      #   settings = {
      #     exclude = {
      #       buftypes = [
      #         "terminal"
      #         "quickfix"
      #       ];
      #       filetypes = [
      #         ""
      #         "checkhealth"
      #         "help"
      #         "lspinfo"
      #         "packer"
      #         "TelescopePrompt"
      #         "TelescopeResults"
      #         "yaml"
      #       ];
      #     };
      #     indent = {
      #       char = "│";
      #     };
      #     scope = {
      #       show_end = false;
      #       show_exact_scope = true;
      #       show_start = false;
      #     };
      #   };
      # };
      #
      # treesitter-context.enable = true; # a nicer/more performant version of context.vim

      tiny-inline-diagnostic.enable = true; # a nicer inline (virtual line replacement) for diagnostic messages

      # highlight-colors.enable = true; # add background highlighting of color strings e.g. #99aa44
      vim-css-color.enable = true; # add background highlighting of color strings e.g. #99aa44 (possibly faster than highlight-colors?)
      gitgutter.enable = true; # show git diff signs in the sign column
      fzf-lua.enable = true; # Fuzzy finder integration # TODO: There's prob a lot more I can do with this
      nvim-tree.enable = true; # nicer file explorer sidebar
      web-devicons.enable = true;

      # better statusline written in lua
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "everforest";
            icons_enabled = true;
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [
              "encoding"
              "filesize"
              "filetype"
            ];
            lualine_y = [
              "lsp_status"
              "venv-selector"
            ];
            lualine_z = [ "location" ];
          };
          inactive_sections = {
            lualine_b = [
              "diff"
              "diagnostics"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [ "filetype" ];
            lualine_y = [ "location" ];
          };
        };
      };

      # better bufferline that works with both tabs and buffers
      bufferline = {
        enable = true;
        settings = {
          options = {
            always_show_bufferline = true;
            offsets = [
              {
                filetype = "NvimTree";
                text = "File Explorer";
                text_align = "center";
                separator = true;
              }
            ];
          };
        };
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      everforest # theme!
      indent-blankline-nvim # show indent line and current block highlight
      term-edit-nvim # allow editing cmdline text in nvim terminal
      flatten-nvim # opening file in terminal in neovim won't nest
      sibling-swap # allow easy swapping of sibling nodes e.g. function args
    ];

    extraConfigVim = readFile ./vim-conf.vim;
    extraConfigLua = /* lua */ ''
      vim.o.updatetime = 250


      require("sibling-swap").setup({
        keymaps = {
            ["<space>l"] = "swap_with_right",
            ["<space>h"] = "swap_with_left",
            ["<space>."] = "swap_with_right_with_opp",
            ["<space>,"] = "swap_with_left_with_opp",
        },
      })

      -- don't keep swapping out the current buffer if already open in another
      local dap = require("dap")
      dap.defaults.fallback.switchbuf = 'useopen,uselast'

      -- nvim-dap mappings
      vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
      vim.keymap.set('n', '<F9>', function() require('dap').terminate() end)
      vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
      vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
      vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
      vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
      vim.keymap.set('n', '<Leader>df', function()
          local widgets = require('dap.ui.widgets')
          widgets.sidebar(widgets.frames).open()
      end)
      vim.keymap.set('n', '<Leader>ds', function()
          local widgets = require('dap.ui.widgets')
          widgets.sidebar(widgets.scopes).open()
      end)
      vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)

      require("term-edit").setup({
          prompt_end = '%$ ',
      })

      require("flatten").setup({})
    '';
  };

  programs.neovim = {
    enable = false;
    viAlias = true;
    vimAlias = true;

    extraConfig = readFile ./vim-conf.vim;

    plugins =
      with pkgs.vimPlugins;
      [

        # TODO: to try next:
        # neotest
        # notebooknavigator.nvim
        # compter.nvim
        # noedim

        # -- Langs --
        vim-nix # DONE:
        julia-vim # CANC:

        # -- Utils --
        fzfWrapper # TODO: unclear on differences between this one and fzf-vim  # DONE:
        fzf-vim # DONE:
        nvim-comment # shortcut to comment lines  # CANC: this apparently already exists??? how???
        vim-tmux-navigator # vim-side of navigating between tmux/vim panes  # DONE:
        vimwiki # allow using alongside obsidian and still doing link nav  # CANC:
        nvim-tree-lua # file explorer sidebar  # DONE:
        bufferline-nvim # better bufferline that works with both tabs and buffers  # DONE:
        term-edit-nvim # allow editing cmdline text in nvim terminal
        flatten-nvim # opening file in terminal in neovim won't nest
        # rsync-nvim # allow auto syncing from a remote source via rsync
        # packer-nvim # some things are easier to install with the packer nvim package manager. # TODO: just using this to build rsync-nvim
        plenary-nvim # helper functions for many other plugins  # CANC:
        sibling-swap # allow easy swapping of sibling nodes e.g. function args
        nvim-surround # make it easier to change quotes/braces around a thing etc.  # DONE:

        # -- testing and debugging
        unstable.neotest # allow running unit tests within neovim  # DONE:
        neotest-python # neotest plugin for pytest  # DONE:
        nvim-dap # debug adapter protocol  # DONE:
        nvim-dap-python # easy config for python dap  # DONE:

        # -- Visual improvements --
        everforest # beautiful colorscheme  # DONE:
        lualine-nvim # better statusline written in lua  # DONE:
        nvim-web-devicons # TODO: unclear if this works w/o font-awesome?  # DONE:
        indent-blankline-nvim # show indent line and current block highlight  # DONE:
        vista-vim # shows a "map" of all the symbols from lsp  # CANC:
        context-vim # DONE:
        # similar to the vscode experimental option that keeps the   # DONE:
        # current scope line in view

        # -- Autocompletion --
        nvim-cmp # DONE:
        cmp-buffer # DONE:
        cmp-spell # DONE:
        cmp-path # DONE:

        # -- Treesitter --
        # (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)) # TODO: ??
        nvim-treesitter.withAllGrammars # DONE:
        cmp-treesitter # DONE:

        # -- LSP --
        nvim-lspconfig # easy configuration setups for a bunch of lsp's  # DONE:
        null-ls-nvim # an lsp server wrapper for any cli utils that don't have dedicated server # DONE:
        cmp-nvim-lsp # DONE:
        cmp-nvim-lsp-signature-help # continues to display signature info as you type  # DONE:

        # -- Snippets --
        luasnip # DONE:
        cmp_luasnip # DONE:
      ]
      ++ [
        # pkgs.unstable.vimPlugins.sibling-swap
        # pkgs.unstable.vimPlugins.neotest
      ];

    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nodePackages.vim-language-server
      # nodePackages.vls

      # -- Python language server stuff --
      # python310Packages.python-lsp-server
      # #python310Packages.pylsp-mypy # TODO: unclear if working
      # python310Packages.pyls-isort
      # python310Packages.python-lsp-black
      # python310Packages.flake8

      # -- Python language server stuff --
      # python311Packages.python-lsp-server
      # python311Packages.pyls-isort
      # python311Packages.python-lsp-black
      # python311Packages.flake8
      # python311Packages.debugpy # required for nvim-dap-python to work I think

      # python312Packages.python-lsp-server
      # python312Packages.pyls-isort
      # python312Packages.python-lsp-black
      # python312Packages.flake8
      # python312Packages.debugpy # required for nvim-dap-python to work I think

      (python3.withPackages (
        ps: with ps; [
          python-lsp-server
          pyls-isort
          python-lsp-black
          flake8
          debugpy
        ]
      ))

      universal-ctags # important for vista-vim to work
      fzf
    ];

    extraPython3Packages = (
      ps: with ps; [
        jedi
        pynvim
      ]
    );
  };
}
