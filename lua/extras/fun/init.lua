local utils = require "lua.utils"
local el = require "lua.extras.elements"
local p = el.p

local utf8 = require "lua-utf8"

local text_splitter = {}

--[[
  Checks if a character is a Japanese character
  @param codepoint - The Unicode codepoint of the character to check
  @return True if the character is Japanese, false otherwise
]]
local function isJapaneseChar(codepoint)
	-- Hiragana (3040-309F)
	if codepoint >= 0x3040 and codepoint <= 0x309F then
		return true
	end

	-- Katakana (30A0-30FF)
	if codepoint >= 0x30A0 and codepoint <= 0x30FF then
		return true
	end

	-- CJK Unified Ideographs - Kanji (4E00-9FFF)
	if codepoint >= 0x4E00 and codepoint <= 0x9FFF then
		return true
	end

	-- Additional Japanese punctuation and symbols
	if codepoint >= 0x3000 and codepoint <= 0x303F then
		return true
	end

	return false
end

--[[
  Splits a string into chunks of Japanese and non-Japanese characters
  Japanese characters include Hiragana, Katakana, and Kanji
  @param text - The text to split
  @return A table of chunks, where each chunk is either all Japanese or all non-Japanese
]]
function text_splitter.splitJapaneseAndLatin(text)
	if not text or text == "" then
		return {}
	end

	local result = {}
	local currentChunk = ""
	local isJapanese = isJapaneseChar(utf8.codepoint(text, 1))

	for _, codepoint in utf8.codes(text) do
		local char = utf8.char(codepoint)
		local charIsJapanese = isJapaneseChar(codepoint)

		-- If we're switching between Japanese and non-Japanese (or vice versa)
		if charIsJapanese ~= isJapanese then
			if currentChunk ~= "" then
				table.insert(result, currentChunk)
				currentChunk = ""
			end
			isJapanese = charIsJapanese
		end

		currentChunk = currentChunk .. char
	end

	-- Add the last chunk if there is one
	if currentChunk ~= "" then
		table.insert(result, currentChunk)
	end

	return result
end

--[[
  Splits text into Japanese and non-Japanese chunks and wraps each chunk in p tags
  with the appropriate class

  @param text - The mixed text to process
  @param class_jp - CSS class for Japanese text chunks
  @param class_en - CSS class for non-Japanese text chunks
  @param p - A function that creates elements with content and class
  @return A table of elements where each chunk is wrapped with the appropriate class
]]
function text_splitter.createTaggedElements(text, class_jp, class_en)
	if not text or text == "" then
		return {}
	end

	local result = {}

	-- Split the text
	local chunks = text_splitter.splitJapaneseAndLatin(text)

	-- Wrap each chunk with appropriate class
	for i, chunk in ipairs(chunks) do
		local isJapanese = isJapaneseChar(utf8.codepoint(chunk, 1))
		local class = isJapanese and class_jp or class_en

		-- Use the p function to create an element with content and class
		table.insert(result, p(chunk, class))
	end

	return result
end

return {
	jap = text_splitter.createTaggedElements,
}
