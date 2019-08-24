
local string_gsub = string.gsub
local string_lower = string.lower
local string_len = string.len
local string_find = string.find
local ipairs = ipairs
local type = type
local empty_whitelist = {} -- Must be empty table.

local function normalize_string(str)
	local sub = string_gsub
	str = string_lower(str)

	-- Normalize certain symbols to alphabetical.
	str = sub(str, "%$", "s")
	str = sub(str, "3", "e")
	str = sub(str, "5", "s")
	str = sub(str, "2", "s")
	str = sub(str, "0", "o")
	str = sub(str, "1", "i")
	str = sub(str, "!", "i")
	str = sub(str, "@", "a")
	str = sub(str, "z", "s")
	str = sub(str, "υ", "u")
	str = sub(str, "ph", "f")
	str = sub(str, "\\/", "v")
	str = sub(str, "%(%)", "o")

	-- Ignore contraction for 'he will'. Common token.
	str = sub(str, "he'll", "")
	
	-- Remove symbols that will interfere with our regexs.
	str = sub(str, "%p", "") -- Punctuation.
	str = sub(str, "%z", "") -- Zero byte.
	str = sub(str, "%c", "") -- Control bytes.
	
	-- Some badwords need special treatment. Preserve the space-break in front of some words using another character.
	str = sub(str, " ass", "~ass") -- Fix false-negatives with strings like "you are an ass".

	-- Ignore false-positives like "same name as server".
	--str = sub(str, "as s%w", "")
	local a, b = string_find(str, "as s%w")
	if a and b then
		local s2 = str:sub(1, a) .. "s~s" .. str:sub(b)
		str = s2
	end

	str = sub(str, "but ", "but~") -- Fix false-positives with strings like "but there arent".
	str = sub(str, "put ", "put~") -- Fix 'puto' (spanish) conflicting with "put on armor/put torch".
	str = sub(str, "had ", "had~") -- Ignore false-positives like "had 3 solars".
	
	-- Remove all spaces.
	str = sub(str, "%s", "")
	
	return str
end



local function range_before(p1, p2, p3, p4)
	if p4 < p1 then
		return true
	end
end

local function range_overlaps(p1, p2, p3, p4)
	if p3 <= p2 and p3 >= p1 then
		return true
	end
	if p1 >= p3 and p1 <= p4 then
		return true
	end
	if p2 <= p4 and p2 >= p3 then
		return true
	end
	if p4 >= p1 and p4 <= p2 then
		return true
	end
	return false
end



-- Function must evaluate to 'true' if the string is bad. Otherwise must return something 'falsy'.
anticurse.check_string = function(table, str)
	local norm = normalize_string(str)
	local havb = false -- Set 'true' if a badword is found.
	
	-- For all words listed in language table.
	for k, v in ipairs(table) do
		local n = nil
		local t = nil
		if type(v) == "string" then
			n = v
			t = empty_whitelist
		elseif type(v) == "table" then
			n = v.word
			t = v.white
		else
			assert(false)
			break -- We shouldn't reach here.
		end

		local p1, p2, p3, p4, isw
		local sf = 1
		local idx = 1

		::retry::

		-- If we're past the end of the string, we're done.
		-- If a badword was already found, we're done.
		if idx > string_len(norm) or havb then
			return havb
		end

		p1, p2 = string_find(norm, n, idx)
		
		-- Find out if the word is whitelisted.
		if p1 then
			--minetest.chat_send_player("MustTest", "# Server: Found word at " .. idx .. ", " .. p1 .. ", " .. p2 .. ".")
			-- Set 'true' if the found word is whitelisted.
			isw = false

			for i, j in ipairs(t) do
				-- Calculate the location to start searching for the whitelisted word from.
				sf = p1 - string_len(j)

				::shiftup::

				sf = sf + 1
				if sf < 1 then sf = 1 end
				--minetest.chat_send_player("MustTest", "# Server: Start search at " .. sf .. ": '" .. j .. "'.")

				-- Get the location of the whitelisted word in the string.
				p3, p4 = string_find(norm, j, sf)

				--if p3 then
				--	minetest.chat_send_player("MustTest",
				--	"# Server: Found '" .. j .. "' at " .. p3 .. ", " .. p4 .. ".")
				--end
                
				-- Find out if the detected possible "badword" overlaps with a whitelisted word.
				if p3 then
					-- If the found whitelisted word occurs *before* the badword (no overlap), then we didn't check successfully.
					-- We must try again, shifting 1 byte farther in the string.
					if range_before(p1, p2, p3, p4) then
						goto shiftup
					end
					if range_overlaps(p1, p2, p3, p4) then
						isw = true
						break -- No need to search rest of whitelisted words.
					end
				end
			end
			
			-- If 'havb' is set once, it is never unset.
			if isw == false then
				--if p1 and p2 then
				--	minetest.chat_send_player("MustTest",
				--		"# Server: BW: " .. sf .. " : " .. p1 .. ", " .. p2 .. ".")
				--end

				havb = true
			end
		end
		
		-- Have we searched the whole string?
		-- Search again if we didn't.
		if p1 then
			-- Advance just one byte, since bad words can be substrings.
			idx = idx + 1
			if not havb then
				-- Then word was in whitelist.
				goto retry
			end
		end
	end
	
	return havb
end
