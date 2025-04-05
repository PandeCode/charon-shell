-- AniList OAuth2 Authentication in Lua
-- Requires: luasocket, dkjson and luafilesystem
-- Install via:
-- luarocks install luasocket
-- luarocks install dkjson
-- luarocks install luafilesystem

-- local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local url = require("socket.url")
local json = require("dkjson")
local lfs = require("lfs")
local os = require("os")

local AniListAuth = {}

-- Configuration settings
AniListAuth.config = {
	client_id = nil,
	client_secret = nil,
	redirect_uri = nil,
	auth_url = "https://anilist.co/api/v2/oauth/authorize",
	token_url = "https://anilist.co/api/v2/oauth/token",
	api_url = "https://graphql.anilist.co",
	cache_dir = os.getenv("HOME") .. "/.cache/anilist-lua",
	token_file = "token.json",
}

-- Helper function for HTTP requests
function AniListAuth:http_request(method, req_url, headers, body)
	local response_body = {}

	headers = headers or {}

	-- Set content length for POST requests with a body
	if body and method == "POST" then
		headers["Content-Length"] = #body
	end

	local request = {
		url = req_url,
		method = method,
		headers = headers,
		source = body and ltn12.source.string(body) or nil,
		sink = ltn12.sink.table(response_body),
	}

	local code, status, response_headers = http.request(request)

	if not code then
		return nil, status
	end

	return {
		status_code = status,
		headers = response_headers,
		text = table.concat(response_body),
	}
end

-- Initialize with your app credentials
function AniListAuth:init(client_id, client_secret, redirect_uri)
	self.config.client_id = client_id
	self.config.client_secret = client_secret
	self.config.redirect_uri = redirect_uri
	self.access_token = nil

	-- Ensure cache directory exists
	self:ensure_cache_dir()

	-- Try to load existing token
	self:load_token()

	return self
end

-- Ensure the cache directory exists
function AniListAuth:ensure_cache_dir()
	local cache_dir = self.config.cache_dir

	-- Check if directory exists
	local attr = lfs.attributes(cache_dir)
	if not attr then
		-- Create directory structure
		local dir_path = ""
		for part in string.gmatch(cache_dir, "[^/]+") do
			dir_path = dir_path .. "/" .. part
			lfs.mkdir(dir_path)
		end
	end
end

-- Load token from cache
function AniListAuth:load_token()
	local token_path = self.config.cache_dir .. "/" .. self.config.token_file
	local file = io.open(token_path, "r")

	if file then
		local content = file:read("*all")
		file:close()

		local token_data, _, err = json.decode(content)
		if err then
			print("Error parsing cached token: " .. err)
			return false
		end

		-- Check if token is expired (with 5 min buffer)
		local current_time = os.time()
		if token_data.expires_at and token_data.expires_at > (current_time + 300) then
			self.access_token = token_data.access_token
			self.token_type = token_data.token_type
			self.expires_in = token_data.expires_in
			self.expires_at = token_data.expires_at
			return true
		else
			print("Cached token expired")
			return false
		end
	end

	return false
end

-- Save token to cache
function AniListAuth:save_token(token_data)
	local token_path = self.config.cache_dir .. "/" .. self.config.token_file
	local file = io.open(token_path, "w")

	if file then
		-- Add expires_at timestamp if not present
		if token_data.expires_in and not token_data.expires_at then
			token_data.expires_at = os.time() + token_data.expires_in
		end

		local content = json.encode(token_data, { indent = true })
		file:write(content)
		file:close()
		return true
	end

	return false
end

-- URL encode parameters
function AniListAuth:url_encode_params(params)
	local encoded = {}
	for k, v in pairs(params) do
		table.insert(encoded, k .. "=" .. url.escape(v))
	end
	return table.concat(encoded, "&")
end

-- Generate the authorization URL that user needs to visit
function AniListAuth:get_auth_url()
	local params = {
		client_id = self.config.client_id,
		redirect_uri = self.config.redirect_uri,
		response_type = "code",
	}

	return self.config.auth_url .. "?" .. self:url_encode_params(params)
end

-- Exchange authorization code for access token
function AniListAuth:get_token(auth_code)
	local body = json.encode({
		grant_type = "authorization_code",
		client_id = self.config.client_id,
		client_secret = self.config.client_secret,
		redirect_uri = self.config.redirect_uri,
		code = auth_code,
	})

	local headers = {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
	}

	local response, err = self:http_request("POST", self.config.token_url, headers, body)
	if not response then
		return nil, "HTTP request failed: " .. (err or "unknown error")
	end

	if response.status_code == 200 then
		local token_data, _, err = json.decode(response.text)
		if err then
			return nil, "Failed to parse token response: " .. err
		end

		self.access_token = token_data.access_token
		self.token_type = token_data.token_type
		self.expires_in = token_data.expires_in

		-- Save token to cache
		self:save_token(token_data)

		return token_data
	else
		return nil, "Failed to get token: " .. response.status_code .. " " .. response.text
	end
end

-- Check if token is valid
function AniListAuth:is_token_valid()
	if not self.access_token then
		return false
	end

	local current_time = os.time()
	if self.expires_at and self.expires_at > (current_time + 300) then
		return true
	end

	print("Cached token expired")
	return false
end

-- Make authenticated API requests to AniList GraphQL endpoint
function AniListAuth:make_api_request(query, variables)
	-- Check if we have a token
	if not self.access_token then
		return nil, "Not authenticated. Call get_token first."
	end

	-- Check token validity before making the request
	if not self:is_token_valid() then
		return nil, "Token is invalid or expired. Please re-authenticate."
	end

	local body = json.encode({
		query = query,
		variables = variables or {},
	})

	local headers = {
		["Authorization"] = "Bearer " .. self.access_token,
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
	}

	local response, err = self:http_request("POST", self.config.api_url, headers, body)
	if not response then
		return nil, "HTTP request failed: " .. (err or "unknown error")
	end

	if response.status_code == 200 then
		local data, _, err = json.decode(response.text)
		if err then
			return nil, "Failed to parse API response: " .. err
		end

		-- Check if we got an error from AniList
		if data.errors then
			local error_msg = "API returned error: "
			for _, error in ipairs(data.errors) do
				error_msg = error_msg .. error.message .. "; "
			end
			return nil, error_msg
		end

		return data
	else
		return nil, "API request failed: " .. response.status_code .. " " .. response.text
	end
end

-- Delete stored token (logout)
function AniListAuth:logout()
	self.access_token = nil
	self.token_type = nil
	self.expires_in = nil
	self.expires_at = nil

	-- Remove token file
	local token_path = self.config.cache_dir .. "/" .. self.config.token_file
	os.remove(token_path)

	return true
end

-- Get user info (example API call)
function AniListAuth:get_user_info()
	local query = [[
        query {
            Viewer {
                id
                name
                avatar {
                    large
                }
                about
                statistics {
                    anime {
                        count
                        minutesWatched
                        episodesWatched
                    }
                    manga {
                        count
                        chaptersRead
                        volumesRead
                    }
                }
            }
        }
    ]]

	return self:make_api_request(query)
end

-- Example usage
function AniListAuth:example()
	-- Create a new AniList auth instance
	local auth = AniListAuth:init("your-client-id", "your-client-secret", "your-redirect-uri")

	-- Check if we already have a valid token
	if auth.access_token and auth:is_token_valid() then
		print("Using cached token: " .. auth.access_token)
	else
		-- 1. Generate authorization URL and have the user open it in a browser
		local auth_url = auth:get_auth_url()
		print("Open this URL in your browser: " .. auth_url)

		-- 2. After user authorizes your app, they'll be redirected with a code
		-- The code will be in the URL: your-redirect-uri?code=auth_code
		print("Enter the authorization code from the redirect URL:")
		local auth_code = io.read()

		-- 3. Exchange the code for an access token
		local token_data, err = auth:get_token(auth_code)
		if err then
			print("Error: " .. err)
			return
		end

		print("Authentication successful! Access token: " .. auth.access_token)
	end

	-- 4. Make an authenticated API request
	local user_data, err = auth:get_user_info()
	if err then
		print("Error: " .. err)
		return
	end

	print("User name: " .. user_data.data.Viewer.name)

	-- Example of getting anime list
	local anime_query = [[
        query {
            Viewer {
                id
                name
                mediaListOptions {
                    scoreFormat
                }
                animeLists {
                    name
                    status
                    entries {
                        id
                        media {
                            id
                            title {
                                romaji
                                english
                            }
                            episodes
                            status
                        }
                        status
                        score
                        progress
                    }
                }
            }
        }
    ]]

	local anime_data, anime_err = auth:make_api_request(anime_query)
	if anime_err then
		print("Error fetching anime list: " .. anime_err)
		return
	end

	-- Process anime data example
	if anime_data and anime_data.data and anime_data.data.Viewer and anime_data.data.Viewer.animeLists then
		for _, list in ipairs(anime_data.data.Viewer.animeLists) do
			print("List: " .. list.name)
			for _, entry in ipairs(list.entries or {}) do
				local title = entry.media.title.english or entry.media.title.romaji
				print(
					string.format(
						"  - %s (Score: %s, Progress: %d/%s)",
						title,
						entry.score,
						entry.progress,
						entry.media.episodes or "?"
					)
				)
			end
		end
	end
end

return AniListAuth
