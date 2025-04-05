{
  outputs = {
    self,
    nixpkgs,
    astal,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    extraPackages =
      (with astal.packages.${system}; [
        battery
        # docs
        io
        astal3
        # astal4
        apps
        auth
        bluetooth
        cava
        greet
        # hyprland
        mpris
        network
        notifd
        powerprofiles
        # river
        tray
        wireplumber
        gjs
      ])
      ++ (with pkgs; [
        dart-sass
        curl
        pkg-config
      ])
      ++ (
        with pkgs.lua52Packages; [
          luaffi
          fennel

          dkjson
          luafilesystem
          luasec
          luasocket
        ]
      );
  in {
    packages.${system}.default = astal.lib.mkLuaPackage {
      inherit pkgs extraPackages;
      name = "charon-shell";
      src = ./.;
      # src = ./blank; # TODO: This messes with LUA_PATH; Change when shipping
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
