-- AniList GraphQL queries for current watching/reading
-- Requires the AniListAuth module from previous examples

local AniListQueries = {}

local open = io.open

local function read_file(path)
	local file = open(path, "rb") -- r read mode and b binary mode
	if not file then
		return nil
	end
	local content = file:read("*a") -- *a or *all reads the whole file
	file:close()
	return content
end

-- Query to get currently reading manga
function AniListQueries:get_current_consuming(auth)
	local query = read_file("./lua/extras/anime/current_anime_manga.graphql")

	return auth:make_api_request(query)
end

-- Parse timestamp to a readable date string
function AniListQueries:format_timestamp(timestamp)
	if not timestamp then
		return "N/A"
	end

	return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- Format time until airing in a human-readable format
function AniListQueries:format_time_until_airing(seconds)
	if not seconds then
		return "N/A"
	end

	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)

	if days > 0 then
		return string.format("%dd %dh %dm", days, hours, minutes)
	elseif hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	else
		return string.format("%dm", minutes)
	end
end

return AniListQueries
