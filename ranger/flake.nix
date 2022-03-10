{
  description = "Real Folk's custom-configured Ranger.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ranger-src = { url = "github:ranger/ranger"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ranger-src, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        python3Packages = pkgs.python3Packages;
        lib = pkgs.lib;
        highlight = pkgs.highlight;
        file = pkgs.file;
        less = pkgs.less;
        w3m = pkgs.w3m;
        imagePreviewSupport = true;

        rifleConf = pkgs.writeText "rifle.conf" (builtins.readFile ./config/rifle.conf);

        ranger = python3Packages.buildPythonApplication rec {
          pname = "ranger";
          version = "master";
          src = ranger-src;
          LC_ALL = "en_US.UTF-8";
          checkInputs = with python3Packages; [ pytestCheckHook ];

          propagatedBuildInputs = [ file python3Packages.astroid python3Packages.pylint ]
            ++ lib.optionals (imagePreviewSupport) [ python3Packages.pillow ];

          preConfigure = ''
                        #UPSTREAM
            						${lib.optionalString (highlight != null) ''
            							sed -i -e 's|^\s*highlight\b|${highlight}/bin/highlight|' \
            								ranger/data/scope.sh
            						''}
            						substituteInPlace ranger/__init__.py \
            							--replace "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"
            						# give file previews out of the box
            						substituteInPlace ranger/config/rc.conf \
            							--replace /usr/share $out/share \
            							--replace "#set preview_script ~/.config/ranger/scope.sh" "set preview_script $out/share/doc/ranger/config/scope.sh"
            					'' + lib.optionalString imagePreviewSupport ''
            						substituteInPlace ranger/ext/img_display.py \
            							--replace /usr/lib/w3m ${w3m}/libexec/w3m
            						# give image previews out of the box when building with w3m
            						substituteInPlace ranger/config/rc.conf \
            							--replace "set preview_images false" "set preview_images true"

                        # CUSTOM
                        # add custom rifle.conf
                        cat "${rifleConf}" > ranger/config/rifle.conf;
            					'';
        };

        rangerWrapped = pkgs.symlinkJoin {
          name = "ranger";
          paths = [ ranger ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/ranger --set PYTHONPATH "out/lib"
          '';
        };

      in
      {
        packages = {
          ranger = rangerWrapped;
        };
        overlay = final: prev: {
          ranger = rangerWrapped;
        };
        defaultPackage = self.packages.${system}.ranger;
      });
}
