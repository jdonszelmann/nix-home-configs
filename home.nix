{ config, lib, pkgs, specialArgs, ... }: {
  home.stateVersion = "24.05";
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
  home = { sessionVariables = { EDITOR = "nvim"; }; };

  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    globals.maplocalleader = " ";

    viAlias = true;
    vimAlias = true;

    # Highlight and remove extra white spaces
    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";

    package = pkgs.neovim-unwrapped;

    plugins = {
      treesitter = {
        enable = true;
        indent = true;

        nixGrammars = true;
        ensureInstalled = "al";
      };
      surround.enable = true;
      cmp-nvim-lsp.enable = true;
      lsp-format.enable = true;

      fugitive.enable = true;

      gitsigns = {
        enable = true;

        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            virt_text = true;
            virt_text_pos = "eol";
          };
        };
      };

      lualine = {
        enable = true;
        theme = "onedark";
      };

      rustaceanvim = {
        enable = true;
        rustAnalyzerPackage = pkgs.rust-analyzer;

        settings = {
          auto_attach = true;
          server = {
            standalone = false;
            cmd = [ "rustup" "run" "nightly" "rust-analyzer" ];
            settings = {
              rust-analyzer = {
                inlayHints = { lifetimeElisionHints = { enable = "always"; }; };
                check = { command = "clippy"; };
              };
              cargo = {
                buildScripts.enable = true;
                features = "all";
                runBuildScripts = true;
                loadOutDirsFromCheck = true;
              };
              checkOnSave = {
                allFeatures = true;
                command = "clippy";
                extraArgs = [ "--no-deps" ];
              };
              procMacro = { enable = true; };
              imports = {
                granularity = { group = "module"; };
                prefix = "self";
              };
              files = {
                excludeDirs =
                  [ ".cargo" ".direnv" ".git" "node_modules" "target" ];
              };

              inlayHints = {
                bindingModeHints.enable = true;
                closureStyle = "rust_analyzer";
                closureReturnTypeHints.enable = "always";
                discriminantHints.enable = "always";
                expressionAdjustmentHints.enable = "always";
                implicitDrops.enable = true;
                lifetimeElisionHints.enable = "always";
                rangeExclusiveHints.enable = true;
              };

              rustc.source = "discover";
            };
            diagnostics = {
              enable = true;
              styleLints.enable = true;
            };
          };
        };
      };

      # Cargo.toml dependency completion
      crates-nvim = {
        enable = true;
      };

      lsp = {
        enable = true;

        servers = {
          cssls.enable = true;
          rnix-lsp.enable = true;
          nil-ls = {
            enable = true;
            extraOptions = {
              nix = {
                maxMemoryMB = 0;
                flake = {
                  autoArchive = true;
                  autoEvalInputs = true;
                  nixpkgsInputName = "nixpkgs";
                };
              };
            };
          };
          clangd = {
            enable = false;
            filetypes = [ "c" "cpp" "objc" "objcpp" ];
          };
          eslint = {
            enable = true;
            filetypes =
              [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
          };
          html = {
            enable = true;
            filetypes = [ "html" ];
          };
          jsonls = {
            enable = true;
            filetypes = [ "json" "jsonc" ];
          };
          pyright = {
            enable = true;
            filetypes = [ "python" ];
          };
          taplo = {
            enable = true;
            filetypes = [ "toml" ];
          };
          bashls = {
            enable = true;

            filetypes = [ "sh" "bash" ];
          };
          tsserver = {
            enable = true;
            filetypes =
              [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
          };

          yamlls = {
            enable = true;
            filetypes = [ "yaml" ];
          };
        };

        inlayHints = true;

        keymaps = {
          lspBuf = {
            "ga" = "code_action";
            "<leader>fmt" = "format";
            "<leader>h" = "hover";
            "<F2>" = "rename";
          };
        };
      };
      fidget.enable = true;
      comment.enable = true;
      floaterm.enable = true;
      telescope = {
        enable = true;

        extensions.ui-select.enable = true;
        extensions.fzf-native.enable = true;
      };
      cmp.enable = true;
      nvim-autopairs.enable = true;
      bufferline = {
        enable = true;
        diagnostics = "nvim_lsp";
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      onedark-nvim
      vim-vsnip
      cmp-vsnip
      nvim-web-devicons
      telescope-ui-select-nvim
      telescope-fzf-native-nvim
    ];

    extraConfigLua = ''
      require("onedark").setup {
          style = "deep",
          highlights = {
              ["@comment"] = {fg = '#77B767'}
          }
      }
      require("onedark").load()

      local cmp = require("cmp")
      cmp.setup {
          snippet = {
              expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
              end,
          },
          window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'vsnip' },
          }, {
              { name = 'buffer' },
          })
      }

      -- key mapping
      local keymap = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }
      local builtin = require('telescope.builtin')

      -- indent and dedent using tab/shift-tab
      vim.keymap.set("n", "<tab>", ">>_")
      vim.keymap.set("n", "<s-tab>", "<<_")
      vim.keymap.set("i", "<s-tab>", "<c-d>")
      vim.keymap.set("v", "<Tab>", ">gv")
      vim.keymap.set("v", "<S-Tab>", "<gv")

      vim.keymap.set('n', 'gr', builtin.lsp_references, {})
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
      vim.keymap.set('n', '<leader>d', builtin.diagnostics, {})
      vim.keymap.set('n', 'gi', builtin.lsp_implementations, {})
      vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, {})

      -- format on wq and x and replace X, W and Q with x, w and q
      vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
      vim.cmd [[cabbrev x execute "Format sync" <bar> x]]
      vim.cmd [[cnoreabbrev W w]]
      vim.cmd [[cnoreabbrev X execute "Format sync" <bar> x]]
      vim.cmd [[cnoreabbrev Q q]]
      vim.cmd [[nnoremap ; :]]

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader><leader>', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fh', builtin.search_history, {})

      -- vim.keymap.set('n', 'gr', builtin.lsp_references, {})
      -- vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
      -- vim.keymap.set('n', 'gi', builtin.lsp_implementations, {})

      -- ============ files and directories ==============

      -- don't change the directory when a file is opened
      -- to work more like an IDE
      vim.opt.autochdir = false

      -- ============ tabs and indentation ==============
      -- automatically indent the next line to the same depth as the current line
      vim.opt.autoindent = true
      vim.opt.smartindent = true
      vim.opt.smarttab = true
      -- backspace across lines
      vim.opt.backspace = { "indent", "eol", "start" }

      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true

      -- ============ line numbers ==============
      -- set number,relativenumber
      vim.opt.number = true
      vim.opt.relativenumber = true

      -- ============ history ==============
      vim.cmd([[
        set undodir=~/.vimdid
        set undofile
      ]])

      vim.opt.undofile = true

      -- ============ miscelaneous ==============
      vim.opt.belloff = "all"

      -- show (usually) hidden characters
      vim.opt.list = true
      vim.opt.listchars = {
        nbsp = "¬",
        extends = "»",
        precedes = "«",
        trail = "·",
        tab = ">-",
      }

      -- paste and yank use global system clipboard
      vim.opt.clipboard = "unnamedplus"

      -- show partial commands entered in the status line
      -- (like show "da" when typing "daw")
      vim.opt.showcmd = true
      vim.opt.mouse = "a"

      vim.opt.modeline = true

      -- highlight the line with the cursor on it
      vim.opt.cursorline = true

      -- enable spell checking (todo: plugin?)
      vim.opt.spell = false

      vim.opt.wrap = false

      -- better search
      vim.cmd([[
        " Better search
        set incsearch
        set ignorecase
        set smartcase
        set gdefault

        nnoremap <silent> n n:call BlinkNextMatch()<CR>
        nnoremap <silent> N N:call BlinkNextMatch()<CR>

        function! BlinkNextMatch() abort
          highlight JustMatched ctermfg=white ctermbg=magenta cterm=bold

          let pat = '\c\%#' . @/
          let id = matchadd('JustMatched', pat)
          redraw

          exec 'sleep 150m'
          call matchdelete(id)
          redraw
        endfunction

        nnoremap <silent> <Space> :silent noh<Bar>echo<CR>
        nnoremap <silent> <Esc> :silent noh<Bar>echo<CR>

        nnoremap <silent> n nzz
        nnoremap <silent> N Nzz
        nnoremap <silent> * *zz
        nnoremap <silent> # #zz
        nnoremap <silent> g* g*zz

        " very magic by default
        nnoremap ? ?\v
        nnoremap / /\v
        cnoremap %s/ %sm/
      ]])

      keymap('n', "t", ":FloatermToggle myfloat<CR>", opts)
      keymap('t', "<Esc>", "<C-\\><C-n>:q<CR>", opts)
    '';

    opts = {
      lazyredraw = false;
      startofline = true;
      showmatch = true;
    };
  };

  # programs.neovim = {
  #   plugins = with pkgs.vimPlugins; [
  #     # figure out lsp capabilities (initialized in lspconfig)
  #     }
  #     {
  #       plugin = nvim-lspconfig;
  #       type = "lua";
  #       config = let inlay-hint = ''
  #           on_attach = function(client, bufnr)
  #             vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  # 
  #             vim.keymap.set("n", "<leader>h", rt.hover_actions.hover_actions, { buffer = bufnr })
  #             vim.keymap.set("n", "<leader>g", generate, { buffer = bufnr })
  #             vim.keymap.set("n", "<leader>em", rt.expand_macro.expand_macro, { buffer = bufnr })
  #             vim.keymap.set("n", "<F2>", rt.ssr.ssr, { buffer = bufnr })
  #           end,
  #           capabilities = capabilities
  #       ''; in ''
  #         y
  # 
  #         local lsp = require('lspconfig')
  #         lsp.nil_ls.setup {
  #           ${inlay-hint},
  #           cmd = { "${pkgs.nil}/bin/nil" }
  #         }
  #         lsp.rust_analyzer.setup {
  #           cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
  #           ${inlay-hint},
  #           settings = {
  #               ["rust-analyzer"] = {
  #                   cargo = {
  #                       allFeatures = true,
  #                       loadOutDirsFromCheck = true,
  #                       runBuildScripts = true,
  #                       buildScripts = {
  #                           enable = true,
  #                       },
  #                   },
  #                   -- Add clippy lints for Rust.
  #                   checkOnSave = {
  #                       allFeatures = true,
  #                       command = "clippy",
  #                       extraArgs = { "--no-deps" },
  #                   },
  #                   procMacro = {
  #                       enable = true
  #                   },
  #                   imports = {
  #                       granularity = {
  #                           group = "module",
  #                       },
  #                       prefix = "self",
  #                   },
  #               },
  #           },
  #         }
  #         lsp.clangd.setup {
  #             ${inlay-hint},
  #             cmd = { "${pkgs.llvmPackages_18.clang-unwrapped}/bin/clangd" },
  #         }
  #         lsp.lua_ls.setup {
  #           ${inlay-hint},
  #           settings = {
  #               cmd = {"${pkgs.lua-language-server}/bin/lua-language-server"},
  #               Lua = {
  #                   runtime = {
  #                       -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
  #                       version = 'LuaJIT',
  #                   },
  #                   diagnostics = {
  #                       -- Get the language server to recognize the `vim` global
  #                       globals = { 'vim' },
  #                   },
  #                   workspace = {
  #                       -- Make the server aware of Neovim runtime files
  #                       library = vim.api.nvim_get_runtime_file("", true),
  #                   },
  #                   -- Do not send telemetry data containing a randomized but unique identifier
  #                   telemetry = {
  #                       enable = false,
  #                   },
  #               },
  #           },
  # 

  #   '';
  # };
}
