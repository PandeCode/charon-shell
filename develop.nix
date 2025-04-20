{
  pkgs ? import <nixpkgs> {},
}:

pkgs.mkShell {
  packages = with pkgs; [
    lua
    (glib.overrideAttrs (old: {
      configureFlags = old.configureFlags ++ [ "--enable-debug" ];
    }))
    lgi
  ];
}
