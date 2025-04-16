pkgs:
with pkgs;
with lua52Packages;
  buildLuarocksPackage {
    pname = "lanes";
    version = "3.17.1-0";
    propagatedBuildInputs = [glibc];
    knownRockspec =
      (fetchurl {
        url = "mirror://luarocks/lanes-3.17.1-0.rockspec";
        sha256 = "1325n0sxnr25f4v8ry8a3h0d46i2r86cxzx53mbh9facgv10m9nz";
      })
      .outPath;
    src = fetchFromGitHub {
      owner = "LuaLanes";
      repo = "lanes";
      rev = "v3.17.1";
      hash = "sha256-MYOngKukfM6YxRSIb8ycVYLriRcGr4M5FLV9q6pqzng=";
    };

    disabled = luaOlder "5.1";

    meta = {
      homepage = "https://github.com/LuaLanes/lanes";
      description = "Multithreading support for Lua";
      license.fullName = "MIT/X11";
    };
  }
