{
  outputs = {
    self,
    nixpkgs,
    astal,
  }: let
    system = "x86_64-linux";
    # pkgs = nixpkgs.legacyPackages.${system};
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          lua = prev.lua5_2;
          luaPackages = prev.lua52Packages;
        })
      ];
    };
    extraPackages =
      (with astal.packages.${system}; [
        io
        astal3
        # astal4

        battery
        apps
        auth
        bluetooth
        cava
        greet
        mpris
        network
        notifd
        powerprofiles
        tray
        wireplumber

        # hyprland
        # river
      ])
      ++ (with pkgs; [
        dart-sass
        glade
        curl
        pkg-config
        inotify-tools
      ])
      ++ (
        with pkgs.luaPackages; [
          luaffi
          fennel
          tl

          luautf8
          jsregexp

          argparse
          luv
          dkjson
          luafilesystem
          luasec
          luasocket

          luarocks-nix

          # (import ./nix/lanes.nix pkgs)
          # (import ./nix/lume.nix pkgs)
        ]
      );
  in {
    packages.${system}.default = astal.lib.mkLuaPackage {
      inherit pkgs extraPackages;
      name = "charon-shell";
      src = ./.;
    };
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
