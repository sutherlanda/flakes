{
  description = "Andrew Sutherland's custom neovim.";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Neovim nightly
    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ### Plugins ###

    # LSP 
    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    rust-tools-nvim = { url = "github:simrat39/rust-tools.nvim"; flake = false; };
    nvim-lsp-ts-utils = { url = "github:jose-elias-alvarez/nvim-lsp-ts-utils"; flake = false; };
    null-ls = { url = "github:jose-elias-alvarez/null-ls.nvim"; flake = false; };

    # Syntax highlighting
    vim-nix = { url = "github:LnL7/vim-nix"; flake = false; };
    vim-glsl = { url = "github:tikhomirov/vim-glsl"; flake = false; };
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };

    # Themes
    tokyonight-nvim = { url = "github:folke/tokyonight.nvim"; flake = false; };

    # NERD
    nerd-tree = { url = "github:preservim/nerdtree"; flake = false; };
    nerd-commenter = { url = "github:preservim/nerdcommenter"; flake = false; };

    # Completion
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    cmp-cmdline = { url = "github:hrsh7th/cmp-cmdline"; flake = false; };
    luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };

    # Misc
    lualine-nvim = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    vim-sensible = { url = "github:tpope/vim-sensible"; flake = false; };
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    telescope-fzy-native = { url = "github:nvim-telescope/telescope-fzy-native.nvim"; flake = false; };
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, neovim-nightly, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          #overlays = [
          #neovim-nightly.overlay
          #];
        };

        buildPlugin = name: pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "master";
          src = builtins.getAttr name inputs;
        };

        plugins = [
          "nvim-lspconfig"
          "rust-tools-nvim"
          "nvim-lsp-ts-utils"
          "null-ls"
          "vim-nix"
          "vim-glsl"
          "nvim-treesitter"
          "tokyonight-nvim"
          "nerd-tree"
          "nerd-commenter"
          "nvim-cmp"
          "cmp-nvim-lsp"
          "cmp-path"
          "cmp-buffer"
          "cmp-cmdline"
          "luasnip"
          "lualine-nvim"
          "vim-rooter"
          "vim-surround"
          "fugitive"
          "vim-sensible"
          "telescope"
          "telescope-fzy-native"
          "plenary"
        ];

        neovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
          vimAlias = true;
          configure = {
            customRC = "source ~/.config/nvim/init.vim"; # Not ideal but if this isn't set, config is not sourced.
            packages.myVimPackage = {
              start = map buildPlugin plugins;
            };
          };
        };
      in

      rec {
        packages = with pkgs; {
          inherit neovim;
        };

        overlay = final: prev: {
          inherit neovim;
        };

        defaultPackage = packages.neovim;
      });
}
