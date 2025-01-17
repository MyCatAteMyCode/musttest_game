
-- Start fresh.
-- Any mods wishing to register additional ores must run after this one.
minetest.clear_registered_ores()
minetest.clear_registered_biomes()
minetest.clear_registered_decorations()



--[==[
collectgarbage"stop" -- we don't want GC heuristics to interfere

local n = 1e8 -- number of runs
local function bench(name, constructor, invokation)
	local func = assert(loadstring(([[
local r = %s
for _ = 1, %d do %s end
]]):format(constructor, n, invokation)))
	local t = minetest.get_us_time()
	func()
	print(name, (minetest.get_us_time() - t) / n, "µs/call")
end

bench("Lua", "nil", "math.random()")
bench("PCG", "PcgRandom(42)", "r:next()")
bench("K&R", "PseudoRandom(42)", "r:next()")
bench("Secure", "assert(SecureRandom())", "r:next_bytes()")
--]==]






if not minetest.global_exists("mapgen") then mapgen = {} end
mapgen.modpath = minetest.get_modpath("mapgen")
mapgen.blames = mapgen.blames or {}

local vector_distance = vector.distance

local reload_or_dofile = function(name, path)
	if minetest.get_modpath("reload") then
		reload.register_file(name, path)
	else
		dofile(path)
	end
end

function mapgen.nearest_player(minp, maxp)
	local x = minp.x + maxp.x / 2
	local y = minp.y + maxp.y / 2
	local z = minp.z + maxp.z / 2
	local p = {x=x, y=y, z=z}

	local z = minetest.get_connected_players()
	local g = {}
	for k, v in ipairs(z) do
		g[#g+1] = v
	end

	table.sort(g, function(a, b)
		return vector_distance(a:get_pos(), p) < vector_distance(b:get_pos(), p)
	end)

	if #g > 0 then
		return g[1]
	end
end

function mapgen.most_blamed()
	local t = {}
	for k, v in pairs(mapgen.blames) do
		t[#t+1] = {name=k, count=v}
	end
	table.sort(t, function(a, b)
		return a.count > b.count
	end)
	if #t > 0 then
		return t[1].name
	end
end

if not minetest.is_singleplayer() then
	if not mapgen.chat_registered then
		-- Set up vars.
		mapgen.report_time = mapgen.report_time or 0
		mapgen.report_chunks = mapgen.report_chunks or 0

		local function notify_chat(minp, maxp, seed)
			local player = mapgen.nearest_player(minp, maxp)
			if player then
				local pname = player:get_player_name()
				if mapgen.blames[pname] then
					mapgen.blames[pname] = mapgen.blames[pname] + 1
				else
					mapgen.blames[pname] = 1
				end
			end

			local time = os.time() -- Time since epoc in seconds.
			if (time - mapgen.report_time) > 120 and mapgen.report_chunks > 0 then
				local blamed = mapgen.most_blamed()

				if blamed and mapgen.report_chunks >= 5 then
					local invisible = gdac_invis.is_invisible(blamed)
					if not invisible then
						local pcount = #(minetest.get_connected_players())
						if pcount and pcount >= 5 then
							minetest.chat_send_all(
								"# Server: Mapgen scrambling. Blame <" .. rename.gpn(blamed) .. "> for lag. Chunks: " ..
								mapgen.report_chunks .. ".")
						end
					end
				end

				mapgen.report_time = time
				mapgen.report_chunks = 0
				mapgen.blames = {} -- Clear blames.
			end
			mapgen.report_chunks = mapgen.report_chunks + 1
		end

		-- Inform players periodically.
		minetest.register_on_generated(notify_chat)

		mapgen.chat_registered = true
	end
end

if not mapgen.files_registered then
	local mp = mapgen.modpath

	-- Shall include useful utilities for Lua mapgens running in the mapgen env.
	minetest.register_mapgen_script(mp .. "/area2d.lua")
	minetest.register_mapgen_script(mp .. "/mapgen-utils.lua")

	-- These files are reloadable. Their functions can be changed at runtime.
	reload_or_dofile("mapgen:shrubs", mp .. "/shrubs.lua")
	reload_or_dofile("mapgen:papyrus", mp .. "/papyrus.lua")
	reload_or_dofile("mapgen:grass", mp .. "/grass.lua")

	if minetest.get_modpath("flowers") then
		reload_or_dofile("mapgen:flowers", mp .. "/flowers.lua")
		reload_or_dofile("mapgen:mushrooms", mp .. "/mushrooms.lua")
	end

	-- Ore and biome registration.
	dofile(mp .. "/mg_alias.lua")
	dofile(mp .. "/mapgen.lua")
	dofile(mp .. "/biome.lua")

	minetest.register_on_generated(function(minp, maxp, seed)
		mapgen.generate_dry_shrubs(minp, maxp, seed)
		mapgen.generate_papyrus(minp, maxp, seed)
		mapgen.generate_grass(minp, maxp, seed)
	end)

	if minetest.get_modpath("flowers") then
		minetest.register_on_generated(function(minp, maxp, seed)
			mapgen.generate_flowers(minp, maxp, seed)
			mapgen.generate_mushrooms(minp, maxp, seed)
		end)
	end

	mapgen.files_registered = true
end


