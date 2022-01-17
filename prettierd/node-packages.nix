# This file has been generated by node2nix 1.9.0. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {
    "core_d-3.2.0" = {
      name = "core_d";
      packageName = "core_d";
      version = "3.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/core_d/-/core_d-3.2.0.tgz";
        sha512 = "waKkgHU2P19huhuMjCqCDWTYjxCIHoB+nnYjI7pVMUOC1giWxMNDrXkPw9QjWY+PWCFm49bD3wA/J+c7BGZ+og==";
      };
    };
    "has-flag-4.0.0" = {
      name = "has-flag";
      packageName = "has-flag";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-flag/-/has-flag-4.0.0.tgz";
        sha512 = "EykJT/Q1KjTWctppgIAgfSO0tKVuZUjhgMr17kqTumMl6Afv3EISleU7qZUzoXDFTAHTDC4NOoG/ZxU3EvlMPQ==";
      };
    };
    "nanolru-1.0.0" = {
      name = "nanolru";
      packageName = "nanolru";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/nanolru/-/nanolru-1.0.0.tgz";
        sha512 = "GyQkE8M32pULhQk7Sko5raoIbPalAk90ICG+An4fq6fCsFHsP6fB2K46WGXVdoJpy4SGMnZ/EKbo123fZJomWg==";
      };
    };
    "prettier-2.5.1" = {
      name = "prettier";
      packageName = "prettier";
      version = "2.5.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/prettier/-/prettier-2.5.1.tgz";
        sha512 = "vBZcPRUR5MZJwoyi3ZoyQlc1rXeEck8KgeC9AwwOn+exuxLxq5toTRDTSaVrXHxelDMHy9zlicw8u66yxoSUFg==";
      };
    };
    "supports-color-8.1.1" = {
      name = "supports-color";
      packageName = "supports-color";
      version = "8.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/supports-color/-/supports-color-8.1.1.tgz";
        sha512 = "MpUEN2OodtUzxvKQl72cUF7RQ5EiHsGvSsVG0ia9c5RbWGL2CI4C7EpPS8UTBIplnlzZiNuV56w+FuNxy3ty2Q==";
      };
    };
  };
in
{
  "@fsouza/prettierd" = nodeEnv.buildNodePackage {
    name = "_at_fsouza_slash_prettierd";
    packageName = "@fsouza/prettierd";
    version = "0.18.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/@fsouza/prettierd/-/prettierd-0.18.0.tgz";
      sha512 = "pWfdKFP6Ssuc0RChatvf0VXyJFFnFwor3c2HZmLSb7+xNGuGb1j5VpB+gqhaotVIXyySciLJ695RLGBTw0XQEw==";
    };
    dependencies = [
      sources."core_d-3.2.0"
      sources."has-flag-4.0.0"
      sources."nanolru-1.0.0"
      sources."prettier-2.5.1"
      sources."supports-color-8.1.1"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "prettier, as a daemon";
      homepage = "https://github.com/fsouza/prettierd#readme";
      license = "ISC";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
