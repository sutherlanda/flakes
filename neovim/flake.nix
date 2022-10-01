{
  description = "Andrew Sutherland's custom neovim.";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";


    ### Plugins ###

    # LSP 
    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    nvim-lsp-ts-utils = { url = "github:jose-elias-alvarez/nvim-lsp-ts-utils"; flake = false; };
    null-ls = { url = "github:jose-elias-alvarez/null-ls.nvim"; flake = false; };
    haskell-vim = { url = "github:neovimhaskell/haskell-vim"; flake = false; };

    # Syntax highlighting
    vim-nix = { url = "github:LnL7/vim-nix"; flake = false; };
    vim-glsl = { url = "github:tikhomirov/vim-glsl"; flake = false; };
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };

    # Formatting
    formatter-nvim = { url = "github:mhartington/formatter.nvim"; flake = false; };

    # Themes
    tokyonight-nvim = { url = "github:folke/tokyonight.nvim"; flake = false; };
    nightfox-nvim = { url = "github:EdenEast/nightfox.nvim"; flake = false; };
    gruvbox-nvim = { url = "github:ellisonleao/gruvbox.nvim"; flake = false; };

    # NERD
    nerd-commenter = { url = "github:preservim/nerdcommenter"; flake = false; };

    # nvim-tree
    nvim-tree = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };

    # Completion
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    cmp-cmdline = { url = "github:hrsh7th/cmp-cmdline"; flake = false; };
    luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };

    # Git
    gitsigns = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };

    # Misc
    lualine-nvim = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    vim-sensible = { url = "github:tpope/vim-sensible"; flake = false; };
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    telescope-fzy-native = { url = "github:nvim-telescope/telescope-fzy-native.nvim"; flake = false; };
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    vim-rzip = { url = "github:lbrayner/vim-rzip"; flake = false; };
    vim-python-virtualenv = { url = "github:sansyrox/vim-python-virtualenv"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          #overlays = [
          #inputs.neovim-nightly-overlay.overlay
          #];
        };

        buildPlugin = name: pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "master";
          src = builtins.getAttr name inputs;
        };

        plugins = [
          "nvim-lspconfig"
          "nvim-lsp-ts-utils"
          "null-ls"
          "haskell-vim"
          "vim-nix"
          "vim-glsl"
          "nvim-treesitter"
          "formatter-nvim"
          "tokyonight-nvim"
          "nightfox-nvim"
          "gruvbox-nvim"
          "nerd-commenter"
          "nvim-tree"
          "nvim-cmp"
          "cmp-nvim-lsp"
          "cmp-path"
          "cmp-buffer"
          "cmp-cmdline"
          "gitsigns"
          "luasnip"
          "lualine-nvim"
          "vim-rooter"
          "vim-surround"
          "fugitive"
          "vim-sensible"
          "telescope"
          "telescope-fzy-native"
          "plenary"
          "vim-rzip"
          "vim-python-virtualenv"
        ];

        neovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
          vimAlias = true;
          configure = {
            customRC = ''
              luafile ${config/lua/global.lua}
              luafile ${config/lua/lsp.lua}
            '';
            packages.myVimPackage = {
              start = map buildPlugin plugins;
            };
          };
        };
      in

      rec {
        packages = with pkgs; {
          inherit neovim;
          config = ./config;
        };

        overlay = final: prev: {
          neovim = packages.neovim;
        };

        defaultPackage = packages.neovim;
      });
}
