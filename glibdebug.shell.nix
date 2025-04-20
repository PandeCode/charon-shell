{ pkgs ? import <nixpkgs> {} }:

let
  # Create a GLib variant with debug symbols
  debugGlib = pkgs.glib.overrideAttrs (oldAttrs: {
    configureFlags = (oldAttrs.configureFlags or []) ++ [
      "--enable-debug=yes"
    ];
  });

  # Create a package set that uses the debug glib
  modifiedPkgs = pkgs.extend (self: super: {
    glib = debugGlib;
  });

in modifiedPkgs.mkShell {
  buildInputs = with modifiedPkgs; [
    glib
    # add any other runtime dependencies your binaries expect
  ];

  shellHook = ''
    echo "Debug-enabled GLib activated"
    echo "GLib version: $(pkg-config --modversion glib-2.0)"

    # Prepend the debug GLib to PKG_CONFIG_PATH and LD_LIBRARY_PATH
    export PKG_CONFIG_PATH="${modifiedPkgs.glib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="${modifiedPkgs.glib.out}/lib:$LD_LIBRARY_PATH"

    # ./dev.sh
  '';
}
