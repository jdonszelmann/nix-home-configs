{ pkgs, ... }:
let
  render-markdown = pkgs.vimUtils.buildVimPlugin {
    name = "render-markdown";
    src = pkgs.fetchFromGitHub {
      owner = "MeanderingProgrammer";
      repo = "markdown.nvim";
      rev = "78ef39530266b3a0736c48b46c3f5d1ab022c7db";
      hash = "sha256-mddnBvIrekHh60Ix6qIYAnv10Mu40LamGI47EXk9wSo=";
    };
  };
  # for lsp/cmp inside markdown code blocks
  otter = pkgs.vimUtils.buildVimPlugin {
    name = "otter";
    src = pkgs.fetchFromGitHub {
      owner = "jmbuhr";
      repo = "otter.nvim";
      rev = "cbb1be0586eae18cbea38ada46af428d2bebf81a";
      hash = "sha256-eya/8rG3O8UFeeBRDa5U8v3qay+q3iFwPnYtdX7ptCA=";
    };
  };
in
{
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

    keymaps = [
      {
        key = "<f2>";
        action = "<cmd>Lspsaga rename<cr>";
      }
      {
        key = "<leader>o";
        action = "<cmd>Lspsaga outline<cr>";
      }
      {
        key = "ga";
        action = "<cmd>Lspsaga code_action<cr>";
      }
    ];

    plugins = {
      treesitter = {
        enable = true;
        indent = true;

        nixGrammars = true;
        ensureInstalled = "all";
      };
      treesitter-context.enable = true;
      surround.enable = true;
      cmp-nvim-lsp.enable = true;
      lsp-format.enable = true;
      fugitive.enable = true;
      lspkind.enable = true;
      crates-nvim.enable = true;
      fidget.enable = true;
      cmp.enable = true;
      nvim-autopairs.enable = true;

      auto-session = {
        enable = true;
        extraOptions = {
          auto_save_enabled = true;
          auto_restore_enabled = true;
          pre_save_cmds = [ "Neotree close" ];
          post_restore_cmds = [ "Neotree filesystem show" ];
        };
      };

      comment = {
        enable = true;

        settings = {
          sticky = true;
          opleader = {
            line = "gc";
            block = "gb";
          };
        };
      };

      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        window = {
          position = "right";
          width = 30;
          mappings = {
            "<bs>" = "navigate_up";
            "." = "set_root";
            "f" = "fuzzy_finder";
            "/" = "filter_on_submit";
            "h" = "show_help";
          };
        };
        filesystem = {
          followCurrentFile.enabled = true;
          filteredItems = {
            hideHidden = false;
            hideDotfiles = false;
            forceVisibleInEmptyFolder = true;
            hideGitignored = false;
          };
        };
      };


      nvim-lightbulb = {
        enable = true;
        settings = {
          autocmd = {
            enabled = true;
            updatetime = 200;
          };
          line = {
            enabled = true;
          };
          number = {
            enabled = true;
            hl = "LightBulbNumber";
          };
          float = {
            enabled = true;
            text = "💡";
          };
          sign = {
            enabled = true;
            text = "💡";
          };
          status_text = {
            enabled = true;
            text = "💡";
          };
        };
      };

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

      lspsaga = {
        enable = true;
        lightbulb.enable = false;
        codeAction.keys = {
          quit = "<Esc>";
        };
      };

      typst-vim = {
        enable = true;
        settings = {
          cmd = "${pkgs.typst}/bin/typst";
          conceal_math = true;
          auto_close_toc = true;
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
              checkOnSave = true;
              check = {
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


      lsp = {
        enable = true;

        servers = {
          astro.enable = true;
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
            enable = true;
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
          marksman.enable = true;
          yamlls = {
            enable = true;
            filetypes = [ "yaml" ];
          };
        };

        inlayHints = true;

        keymaps = {
          lspBuf = {
            "<leader>fmt" = "format";
            "<leader>h" = "hover";
          };
        };
      };
      floaterm = {
        enable = true;
        opener = "edit";
        width = 0.8;
        height = 0.8;
      };
      telescope = {
        enable = true;

        extensions.ui-select.enable = true;
        extensions.fzf-native.enable = true;

        settings = {
          defaults = {
            path_display = [ "smart" ];
            layout_strategy = "horizontal";
            layout_config = {
              width = 0.99;
              height = 0.99;
            };
          };
        };
      };
      bufferline = {
        enable = true;
        diagnostics = "nvim_lsp";
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      onedark-nvim
      vim-vsnip
      cmp-vsnip
      cmp-path
      cmp-spell
      cmp-tabnine
      nvim-web-devicons
      telescope-ui-select-nvim
      telescope-fzf-native-nvim
      vim-suda
      render-markdown
      otter
      vim-astro
    ];

    extraConfigLua = builtins.readFile ./config.lua;

    opts = {
      lazyredraw = false;
      startofline = true;
      showmatch = true;
    };
  };
}
