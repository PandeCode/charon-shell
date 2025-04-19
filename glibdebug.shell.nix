{pkgs ? import <nixpkgs> {}}: let
  debugGlib = pkgs.glib.overrideAttrs (oldAttrs: {
    configureFlags =
      (oldAttrs.configureFlags or [])
      ++ [
        "--enable-debug=yes"
      ];
  });

  # Create a new package set with our debug glib
  modifiedPkgs = pkgs.extend (self: super: {
    glib = debugGlib;
  });
in
  modifiedPkgs.mkShell {
    buildInputs = with modifiedPkgs; [
      glib
      # Add any other dependencies you need here
    ];

    # Ensure the debug version is used
    shellHook = ''
      echo "Debug-enabled GLib activated"
      echo "GLib version: $(pkg-config --modversion glib-2.0)"
      export PKG_CONFIG_PATH="${modifiedPkgs.glib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
      export LD_LIBRARY_PATH="${modifiedPkgs.glib}/lib:$LD_LIBRARY_PATH"
    '';
  }
