---@class AniListMediaCollection
---@field anime table[] List of currently watching anime
---@field manga table[] List of currently reading manga
local AniListMediaCollection = {}

---@class AnimeEntry
---@field id number The anime entry ID
---@field score number User's score for the anime
---@field mediaId number The anime media ID
---@field title table The anime title object
---@field title.romaji string Romaji title
---@field title.english string|nil English title
---@field episodes number|nil Total episodes
---@field coverImage string Medium size cover image URL
---@field nextAiringEpisode table|nil Information about the next airing episode
---@field nextAiringEpisode.airingAt number|nil Unix timestamp of when the next episode airs
---@field nextAiringEpisode.episode number|nil The episode number that will air next
---@field tags string[] List of tags associated with the anime
---@field progress number Number of episodes watched by the user

---@class MangaEntry
---@field id number The manga entry ID
---@field score number User's score for the manga
---@field mediaId number The manga media ID
---@field title table The manga title object
---@field title.romaji string Romaji title
---@field title.english string|nil English title
---@field chapters number|nil Total chapters
---@field volumes number|nil Total volumes
---@field coverImage string Large size cover image URL
---@field progress number Number of chapters read by the user
---@field progressVolumes number|nil Number of volumes read by the user

--- Create a new AniListMediaCollection object
---@param jsonData table The parsed JSON data from dkjson
---@return AniListMediaCollection
function AniListMediaCollection:new(jsonData)
	local collection = setmetatable({
		anime = {},
		manga = {},
	}, { __index = AniListMediaCollection })

	if jsonData then
		collection:parseJsonData(jsonData)
	end

	return collection
end

--- Parse the JSON data from AniList GraphQL API
---@param jsonData table The parsed JSON data from dkjson
function AniListMediaCollection:parseJsonData(json)
	local jsonData = json.data

	-- Parse anime data
	if jsonData.MediaListCollection and jsonData.MediaListCollection.lists then
		for _, list in ipairs(jsonData.MediaListCollection.lists) do
			if list.entries then
				for _, entry in ipairs(list.entries) do
					if entry.media then
						local tags = {}
						if entry.media.tags then
							for _, tag in ipairs(entry.media.tags) do
								table.insert(tags, tag.name)
							end
						end

						table.insert(self.anime, {
							id = entry.id,
							score = entry.score,
							mediaId = entry.media.id,
							title = {
								romaji = entry.media.title and entry.media.title.romaji,
								english = entry.media.title and entry.media.title.english,
							},
							episodes = entry.media.episodes,
							coverImage = entry.media.coverImage and entry.media.coverImage.medium,
							nextAiringEpisode = entry.media.nextAiringEpisode and {
								airingAt = entry.media.nextAiringEpisode.airingAt,
								episode = entry.media.nextAiringEpisode.episode,
							} or nil,
							tags = tags,
							progress = entry.progress,
						})
					end
				end
			end
		end
	end

	-- Parse manga data
	if jsonData.MangaListCollection and jsonData.MangaListCollection.lists then
		for _, list in ipairs(jsonData.MangaListCollection.lists) do
			if list.entries then
				for _, entry in ipairs(list.entries) do
					if entry.media then
						table.insert(self.manga, {
							id = entry.id,
							score = entry.score,
							mediaId = entry.media.id,
							title = {
								romaji = entry.media.title and entry.media.title.romaji,
								english = entry.media.title and entry.media.title.english,
							},
							chapters = entry.media.chapters,
							volumes = entry.media.volumes,
							coverImage = entry.media.coverImage and entry.media.coverImage.large,
							progress = entry.progress,
							progressVolumes = entry.progressVolumes,
						})
					end
				end
			end
		end
	end
end

--- Get anime by ID
---@param id number The anime media ID
---@return AnimeEntry|nil
function AniListMediaCollection:getAnimeById(id)
	for _, anime in ipairs(self.anime) do
		if anime.mediaId == id then
			return anime
		end
	end
	return nil
end

--- Get manga by ID
---@param id number The manga media ID
---@return MangaEntry|nil
function AniListMediaCollection:getMangaById(id)
	for _, manga in ipairs(self.manga) do
		if manga.mediaId == id then
			return manga
		end
	end
	return nil
end

--- Get next airing anime list sorted by air date
---@return AnimeEntry[]
function AniListMediaCollection:getNextAiringAnime()
	local airingAnime = {}

	for _, anime in ipairs(self.anime) do
		if anime.nextAiringEpisode and anime.nextAiringEpisode.airingAt then
			table.insert(airingAnime, anime)
		end
	end

	table.sort(airingAnime, function(a, b)
		return a.nextAiringEpisode.airingAt < b.nextAiringEpisode.airingAt
	end)

	return airingAnime
end

--- Get anime with specific tag
---@param tagName string The tag name to search for
---@return AnimeEntry[]
function AniListMediaCollection:getAnimeByTag(tagName)
	local result = {}

	for _, anime in ipairs(self.anime) do
		for _, tag in ipairs(anime.tags) do
			if tag == tagName then
				table.insert(result, anime)
				break
			end
		end
	end

	return result
end

--- Get anime progress status
---@param anime AnimeEntry
---@return string Status description
function AniListMediaCollection:getAnimeProgressStatus(anime)
	if not anime.episodes then
		return string.format("%d/?", anime.progress)
	end
	return string.format("%d/%d", anime.progress, anime.episodes)
end

--- Get manga progress status
---@param manga MangaEntry
---@return string Status description of chapters
---@return string|nil Status description of volumes
function AniListMediaCollection:getMangaProgressStatus(manga)
	local chapterStatus
	if not manga.chapters then
		chapterStatus = string.format("%d/?", manga.progress)
	else
		chapterStatus = string.format("%d/%d", manga.progress, manga.chapters)
	end

	local volumeStatus
	if manga.progressVolumes then
		if not manga.volumes then
			volumeStatus = string.format("%d/?", manga.progressVolumes)
		else
			volumeStatus = string.format("%d/%d", manga.progressVolumes, manga.volumes)
		end
	end

	return chapterStatus, volumeStatus
end

--- Format Unix timestamp to readable date
---@param timestamp number Unix timestamp
---@return string Formatted date string
function AniListMediaCollection:formatTimestamp(timestamp)
	return os.date("%Y-%m-%d %H:%M", timestamp)
end

return AniListMediaCollection
