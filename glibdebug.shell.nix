{pkgs ? import <nixpkgs> {}}: let
  debugGlib = pkgs.glib.overrideAttrs (oldAttrs: {
    dontStrip = true;
    configureFlags =
      (oldAttrs.configureFlags or [])
      ++ [
        "--enable-debug=yes"
      ];
  });

  dgobject-introspection = pkgs.gobject-introspection.overrideAttrs (oldAttrs: {
    dontStrip = true;
    configureFlags =
      (oldAttrs.configureFlags or [])
      ++ [
        "--enable-debug=yes"
      ];
  });

  modifiedPkgs = pkgs.extend (self: super: {
    glib = debugGlib;
    gobject-introspection = dgobject-introspection;
  });
in
  modifiedPkgs.mkShell {
    buildInputs = with modifiedPkgs; [
      glib
      # cairo
      gobject-introspection
      # luaPackages.lgi
    ];

    shellHook = with modifiedPkgs; ''
      echo "Debug-enabled GLib activated"
      echo "GLib version: $(pkg-config --modversion glib-2.0)"

      export PKG_CONFIG_PATH="${glib.dev}/lib/pkgconfig:${cairo.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
      export LD_LIBRARY_PATH="${glib.out}/lib:${cairo.out}/lib:$LD_LIBRARY_PATH"

      export GI_TYPELIB_PATH="${gobject-introspection}/lib/girepository-1.0:${cairo}/lib/girepository-1.0:$GI_TYPELIB_PATH"

      # You can now run: lua yourscript.lua
    '';
  }
