local socket = require("socket")
local url = require("socket.url")
local utils = require("lua.utils")
local AniListAuth = require("lua.extras.anime.anilist_auth")
local AniListQueries = require("lua.extras.anime.anilist_graphql")
local AniListMediaCollection = require("lua.extras.anime.current_anime_manga")
local lfs = require("lfs") -- LuaFileSystem for file operations
local json = require("dkjson") -- dkjson for JSON parsing

-- Configuration file path
local config_path = os.getenv("HOME") .. "/.config/charon-shell/config.json"

-- Function to load and decode the config file
local function load_config()
	local file = io.open(config_path, "r")
	if not file then
		print("Error: Configuration file missing: " .. config_path)
		return nil
	end

	local content = file:read("*a")
	file:close()

	local config, pos, err = json.decode(content, 1, nil)
	if err then
		print("Error parsing config file: " .. err)
		return nil
	end

	return config
end

-- Load configuration parameters
local config = load_config()
if not config then
	return nil
end

-- Now initialize authentication using parameters from the config file
local auth = AniListAuth:init(config.client_id, config.client_secret, config.redirect_url)

local cache_dir = os.getenv("HOME") .. "/.cache/charon-shell/"
local cache_file = cache_dir .. "current_consuming_cache.lua"
local cache_duration = 24 * 60 * 60 -- 1 day in seconds

local function http_response(client, code, content)
	local headers = {
		"HTTP/1.1 " .. code,
		"Content-Type: text/html",
		"Content-Length: " .. #content,
		"Connection: close",
		"",
		content,
	}
	client:send(table.concat(headers, "\r\n"))
	client:close()
end

local function start_auth_server()
	local server = assert(socket.bind("localhost", 8090))
	local ip, port = server:getsockname()
	print("Waiting for authorization on " .. ip .. " http://localhost:" .. port)

	server:settimeout(120) -- 2 minutes timeout

	local auth_code = nil

	local client = server:accept()
	if client then
		client:settimeout(5)
		local request = client:receive()

		if request then
			local _, _, path = request:find("GET (.*) HTTP/")
			if path then
				local parsed = url.parse(path)
				if parsed.query then
					local params = {}
					for k, v in parsed.query:gmatch("([^&=]+)=([^&=]+)") do
						params[k] = url.unescape(v)
					end
					auth_code = params.code

					http_response(
						client,
						"200 OK",
						[[
                            <html>
                                <head><title>Authorization Successful</title></head>
                                <body>
                                    <h1>Authorization Successful</h1>
                                    <p>You can close this window and return to the application.</p>
                                    <script>window.close();</script>
                                </body>
                            </html>
                        ]]
					)
				end
			end
		else
			http_response(client, "400 Bad Request", "<html><body>Bad Request</body></html>")
		end
	end

	server:close()
	return auth_code
end

local function load_cache()
	local file = io.open(cache_file, "r")
	if file then
		local content = file:read("*a")
		file:close()
		return load(content)()
	end
	return nil
end

local function save_cache(data)
	os.execute("mkdir -p " .. cache_dir)
	local file = io.open(cache_file, "w")
	if file then
		file:write("return " .. utils.serialize(data))
		file:close()
	end
end

local function is_cache_valid()
	local attr = lfs.attributes(cache_file)
	if attr then
		local age = os.time() - attr.modification
		return age < cache_duration
	end
	return false
end

local function get_current_consuming(force_auth)
	if not force_auth and is_cache_valid() then
		return load_cache()
	end

	-- Check if we need to authenticate
	if not auth.access_token then
		local auth_url = auth:get_auth_url()
		print("Please visit this URL to authorize the application:")
		print(auth_url)

		os.execute("xdg-open '" .. auth_url .. "'")

		local auth_code = start_auth_server()

		if not auth_code then
			print("Failed to get authorization code")
			return nil
		end

		print("Authorization code received: " .. auth_code)

		local _, err = auth:get_token(auth_code)
		if err then
			print("Authentication error: " .. err)
			return nil
		end
	end

	-- Reinitialize auth to update token if needed
	auth = AniListAuth:init(config.client_id, config.client_secret, config.redirect_url)
	local data = AniListMediaCollection:new(AniListQueries:get_current_consuming(auth))
	save_cache(data)
	return data
end

return get_current_consuming
