pkgs:
with pkgs;
with lua52Packages;
  buildLuarocksPackage {
    pname = "lume";
    version = "2.3.0-0";
    knownRockspec =
      (fetchurl {
        url = "mirror://luarocks/lume-2.3.0-0.rockspec";
        sha256 = "1v2jk8173kf205zkacsmncwrjk6rfs79p63x3n1wzqz4512y4lc0";
      })
      .outPath;
    src = fetchFromGitHub {
      owner = "rxi";
      repo = "lume";
      rev = "v2.3.0";
      hash = "sha256-Q9+sLbJ8PaJ2xx/7UCkhnv5yCHueJ4hDdCPaVEQ45KA=";
    };

    disabled = luaOlder "5.1" || luaAtLeast "5.4";

    meta = {
      homepage = "https://github.com/rxi/lume";
      description = "A collection of functions for Lua, geared towards game development.";
      license.fullName = "MIT";
    };
  }
