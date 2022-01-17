{
  description = "Builds mosh from source (latest). Used to enable truecolor.";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Mosh
    mosh-src = { url = "github:mobile-shell/mosh?ref=master"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, mosh-src, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        mosh-overlay = final: prev: with nixpkgs.legacyPackages.${system}; {
          mosh = final.stdenv.mkDerivation rec {
            pname = "mosh";
            version = "1.3.2";
            src = mosh-src;
            nativeBuildInputs = [ autoreconfHook pkg-config makeWrapper ];
            buildInputs = [
              protobuf
              ncurses
              zlib
              openssl
              bash-completion
            ]
            ++ (with perlPackages; [ perl IOTty ])
            ++ lib.optional final.stdenv.isLinux libutempter;

            configurePhase = ''
              ./autogen.sh;
              ./configure;
            '';

            installPhase = '' 
              make prefix=$out install;
              wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB; 
            ''
            + final.lib.strings.optionalString (glibcLocales != null)
              "wrapProgram $out/bin/mosh-server --set LOCALE_ARCHIVE ${glibcLocales}/lib/locale/locale-archive;";
          };
        };
        pkgs = import nixpkgs { inherit system; overlays = [ mosh-overlay ]; };
      in
      rec {
        packages = with pkgs; {
          inherit mosh;
        };

        overlay = final: prev: with pkgs; {
          inherit mosh;
        };

        defaultPackage = packages.mosh;
      });
} 
