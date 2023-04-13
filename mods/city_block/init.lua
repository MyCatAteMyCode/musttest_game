-- Minetest mod "City block"
-- City block disables use of water/lava buckets and also sends aggressive players to jail
-- 2016.02 - improvements suggested by rnd. removed spawn_jailer support. some small fixes and improvements.

-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

if not minetest.global_exists("city_block") then city_block = {} end
city_block.blocks = city_block.blocks or {}
city_block.filename = minetest.get_worldpath() .. "/city_blocks.txt"
city_block.modpath = minetest.get_modpath("city_block")

-- Localize for performance.
local vector_distance = vector.distance
local vector_round = vector.round
local vector_add = vector.add
local vector_equals = vector.equals
local math_random = math.random



function city_block.on_punch(pos, node, puncher, pt)
	if not pos or not node or not puncher or not pt then
		return
	end

	local pname = puncher:get_player_name()

	if minetest.test_protection(pos, pname) then
		return
	end

	local wielded = puncher:get_wielded_item()
	if wielded:get_name() == "rosestone:head" and wielded:get_count() >= 8 then
		for i, v in ipairs(city_block.blocks) do
			if vector_equals(v.pos, pos) then
				if not v.is_jail then
					local p1 = vector_add(pos, {x=-1, y=0, z=-1})
					local p2 = vector_add(pos, {x=1, y=0, z=1})
					local positions, counts = minetest.find_nodes_in_area(p1, p2, "griefer:grieferstone")

					if counts["griefer:grieferstone"] == 8 then
						v.is_jail = true
						local meta = minetest.get_meta(pos)
						local infotext = meta:get_string("infotext")
						infotext = infotext .. "\nJail Marker"
						meta:set_string("infotext", infotext)

						city_block:save()

						wielded:take_item(8)
						puncher:set_wielded_item(wielded)

						minetest.chat_send_player(pname, "# Server: Jail position marked!")
						return
					end
				end
			end
		end
	end
end



-- Returns a table of the N-nearest city-blocks to a given position.
-- The return value format is: {{pos, owner}, {pos, owner}, ...}
-- Note: only returns blocks in the same realm! See RC mod.
-- The 'rangelim' parameter is optional, if specified, blocks farther than this
-- are ignored entirely.
function city_block:nearest_blocks_to_position(pos, num, rangelim)
	local get_rn = rc.current_realm_at_pos
	local realm = get_rn(pos)

	-- Copy the master table's indices so we don't modify it.
	-- We do not need to copy the inner table data itself. Just the indices.
	-- Only copy over blocks in the same realm, too.
	local blocks = {}
	local sblocks = self.blocks
	for i=1, #sblocks, 1 do
		local p = sblocks[i].pos
		if rangelim then
			if vector_distance(p, pos) < rangelim then
				if get_rn(p) == realm then
					blocks[#blocks+1] = sblocks[i]
				end
			end
		else
			if get_rn(p) == realm then
				blocks[#blocks+1] = sblocks[i]
			end
		end
	end

	-- Sort blocks, nearest blocks first.
	table.sort(blocks,
		function(a, b)
			local d1 = vector_distance(a.pos, pos)
			local d2 = vector_distance(b.pos, pos)
			return d1 < d2
		end)

	-- Return N-nearest blocks (should be at the front of the sorted table).
	local ret = {}
	for i=1, num, 1 do
		if i <= #blocks then
			ret[#ret+1] = blocks[i]
		else
			break
		end
	end
	return ret
end

function city_block:nearest_jails_to_position(pos, num, rangelim)
	local get_rn = rc.current_realm_at_pos
	local realm = get_rn(pos)

	-- Copy the master table's indices so we don't modify it.
	-- We do not need to copy the inner table data itself. Just the indices.
	-- Only copy over blocks in the same realm, too.
	local blocks = {}
	local sblocks = self.blocks
	for i=1, #sblocks, 1 do
		local v = sblocks[i]
		local p = v.pos
		if v.is_jail then
			if rangelim then
				if vector_distance(p, pos) < rangelim then
					if get_rn(p) == realm then
						blocks[#blocks+1] = v
					end
				end
			else
				if get_rn(p) == realm then
					blocks[#blocks+1] = v
				end
			end
		end
	end

	-- Sort blocks, nearest blocks first.
	table.sort(blocks,
		function(a, b)
			local d1 = vector_distance(a.pos, pos)
			local d2 = vector_distance(b.pos, pos)
			return d1 < d2
		end)

	-- Return N-nearest blocks (should be at the front of the sorted table).
	local ret = {}
	for i=1, num, 1 do
		if i <= #blocks then
			ret[#ret+1] = blocks[i]
		else
			break
		end
	end
	return ret
end



function city_block.erase_jail(pos)
	pos = vector_round(pos)
	local b = city_block.blocks
	for k, v in ipairs(b) do
		if vector_equals(pos, v.pos) then
			local meta = minetest.get_meta(pos)
			local pname = meta:get_string("owner")
			local dname = rename.gpn(pname)
			meta:set_string("infotext", "City Marker (Placed by <" .. dname .. ">!)")

			v.is_jail = nil
			city_block:save()
			return
		end
	end
end



-- Get city information for the given position.
function city_block.city_info(pos)
	pos = vector_round(pos)
	local marker = city_block:nearest_blocks_to_position(pos, 1, 100)
	if marker and marker[1] then
		-- Covers a 45x45x45 area.
		local r = 22
		local vpos = marker[1].pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return marker[1]
		end
	end
end



function city_block:save()
	local datastring = minetest.serialize(self.blocks)
	if not datastring then
		return
	end

	minetest.safe_file_write(self.filename, datastring)

	--[[
	local file, err = io.open(self.filename, "w")
	if err then
		return
	end
	file:write(datastring)
	file:close()
	--]]
end

function city_block:load()
	local file, err = io.open(self.filename, "r")
	if err then
		self.blocks = {}
		return
	end
	self.blocks = minetest.deserialize(file:read("*all"))
	if type(self.blocks) ~= "table" then
		self.blocks = {}
	end
	file:close()
end

function city_block:in_city(pos)
	pos = vector_round(pos)
	-- Covers a 45x45x45 area.
	local r = 22
	local blocks = self.blocks
	for i=1, #blocks, 1 do -- Convenience of ipairs() does not justify its overhead.
		local v = blocks[i]
		local vpos = v.pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return true
		end
	end
	return false
end

function city_block:in_city_suburbs(pos)
	pos = vector_round(pos)
	local r = 44
	local blocks = self.blocks
	for i=1, #blocks, 1 do -- Convenience of ipairs() does not justify its overhead.
		local v = blocks[i]
		local vpos = v.pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return true
		end
	end
	return false
end

function city_block:in_safebed_zone(pos)
	-- Covers a 111x111x111 area.
	pos = vector_round(pos)
	local r = 55
	local blocks = self.blocks
	for i=1, #blocks, 1 do -- Convenience of ipairs() does not justify its overhead.
		local v = blocks[i]
		local vpos = v.pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return true
		end
	end
	return false
end

function city_block:in_no_tnt_zone(pos)
	pos = vector_round(pos)
	local r = 50
	local blocks = self.blocks
	for i=1, #blocks, 1 do -- Convenience of ipairs() does not justify its overhead.
		local v = blocks[i]
		local vpos = v.pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return true
		end
	end
	return false
end

function city_block:in_no_leecher_zone(pos)
	pos = vector_round(pos)
	local r = 100
	local blocks = self.blocks
	for i=1, #blocks, 1 do -- Convenience of ipairs() does not justify its overhead.
		local v = blocks[i]
		local vpos = v.pos
		if pos.x >= (vpos.x - r) and pos.x <= (vpos.x + r) and
			 pos.z >= (vpos.z - r) and pos.z <= (vpos.z + r) and
			 pos.y >= (vpos.y - r) and pos.y <= (vpos.y + r) then
			return true
		end
	end
	return false
end



if not city_block.run_once then
	city_block:load()

	minetest.register_node("city_block:cityblock", {
		description = "Lawful Zone Marker [Marks a 45x45x45 area as a city.]\n\nSaves your bed respawn position, if someone killed you within the city area.\nMurderers and trespassers will be sent to jail if caught in a city.\nPrevents the use of ore leeching equipment within 100 meters radius.\nPrevents mining with TNT nearby.",
		tiles = {"moreblocks_circle_stone_bricks.png^default_tool_mesepick.png"},
		is_ground_content = false,
		groups = utility.dig_groups("obsidian", {
			immovable=1,
		}),
		is_ground_content = false,
		sounds = default.node_sound_stone_defaults(),

		after_place_node = function(pos, placer)
			if placer and placer:is_player() then
				local pname = placer:get_player_name()
				local meta = minetest.get_meta(pos)
				local dname = rename.gpn(pname)
				meta:set_string("rename", dname)
				meta:set_string("owner", pname)
				meta:set_string("infotext", "City Marker (Placed by <" .. dname .. ">!)")
				table.insert(city_block.blocks, {
					pos = vector_round(pos),
					owner = pname,
					time = os.time(),
				})
				city_block:save()
			end
		end,

		-- We don't need an `on_blast` func because TNT calls `on_destruct` properly!
		on_destruct = function(pos)
			-- The cityblock may not exist in the list if the node was created by falling,
			-- and was later dug.
			for i, EachBlock in ipairs(city_block.blocks) do
				if vector_equals(EachBlock.pos, pos) then
					table.remove(city_block.blocks, i)
					city_block:save()
				end
			end
		end,

		-- Called by rename LBM.
		_on_rename_check = function(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			-- Nobody placed this block.
			if owner == "" then
				return
			end
			local dname = rename.gpn(owner)

			meta:set_string("rename", dname)
			meta:set_string("infotext", "City Marker (Placed by <" .. dname .. ">!)")
		end,

		on_punch = function(...)
			return city_block.on_punch(...)
		end,
	})

	minetest.register_craft({
		output = 'city_block:cityblock',
		recipe = {
			{'default:pick_mese', 'farming:hoe_mese', 'default:sword_diamond'},
			{'chests:chest_locked', 'default:goldblock', 'default:sandstone'},
			{'default:obsidianbrick', 'default:mese', 'cobble_furnace:inactive'},
		}
	})

	minetest.register_privilege("disable_pvp", "Players cannot damage players with this priv by punching.")

	minetest.register_on_punchplayer(function(...)
		return city_block.on_punchplayer(...)
	end)

	local c = "city_block:core"
	local f = city_block.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	city_block.run_once = true
end



function city_block:get_adjective()
  local adjectives = {
    "murdering",
    "slaying",
    "killing",
    "whacking",
    "trashing",
    "fatally attacking",
    "fatally harming",
    "doing away with",
    "giving the Chicago treatment to",
    "fatally thrashing",
    "fatally stabbing",
  }
  return adjectives[math_random(1, #adjectives)]
end



local murder_messages = {
	"<v> collapsed from <k>'s brutal attack.",
	"<k>'s <w> apparently wasn't such an unusual weapon after all, as <v> found out.",
	"<k> killed <v> with great prejudice.",
	"<v> died from <k>'s horrid slaying.",
	"<v> fell prey to <k>'s deadly <w>.",
	"<k> went out of <k_his> way to slay <v> with <k_his> <w>.",
	"<v> danced <v_himself> to death under <k>'s craftily wielded <w>.",
	"<k> used <k_his> <w> to kill <v> with prejudice.",
	"<k> made a splortching sound with <v>'s head.",
	"<v> got flattened by <k>'s skillfully handled <w>.",
	"<v> became prey for <k>.",
	"<v> didn't get out of <k>'s way in time.",
	"<v> SAW <k> coming with <k_his> <w>. Didn't get away in time.",
	"<v> made no real attempt to get out of <k>'s way.",
	"<k> barreled through <v> as if <v_he> wasn't there.",
	"<k> sent <v> to that place where kindling wood isn't needed.",
	"<v> didn't suspect that <k> meant <v_him> any harm.",
	"<v> fought <k> to the death and lost painfully.",
	"<v> knew <k> was wielding <k_his> <w> but didn't guess what <k> meant to do with it.",
	"<k> clonked <v> over the head using <k_his> <w> with silent skill.",
	"<k> made sure <v> didn't see that coming!",
	"<k> has decided <k_his> favorite weapon is <k_his> <w>.",
	"<v> did the mad hatter dance just before being killed with <k>'s <w>.",
	"<v> played the victim to <k>'s bully behavior!",
	"<k> used <v> for weapons practice with <k_his> <w>.",
	"<v> failed to avoid <k>'s oncoming weapon.",
	"<k> successfully got <v> to complain of a headache.",
	"<v> got <v_himself> some serious hurt from <k>'s <w>.",
	"Trying to talk peace to <k> didn't win any for <v>.",
	"<v> was brutally slain by <k>'s <w>.",
	"<v> jumped the mad-hatter dance under <k>'s <w>.",
	"<v> got <v_himself> a fatal mauling by <k>'s <w>.",
	"<k> just assassinated <v> with <k_his> <w>.",
	"<k> split <v>'s wig.",
	"<k> took revenge on <v>.",
	"<k> flattened <v>.",
	"<v> played dead. Permanently.",
	"<v> never saw what hit <v_him>.",
	"<k> took <v> by surprise.",
	"<v> was assassinated.",
	"<k> didn't take any prisoners from <v>.",
	"<k> pinned <v> to the wall with <k_his> <w>.",
	"<v> failed <v_his> weapon checks.",
}

function city_block.murder_message(killer, victim, sendto)
	local msg = murder_messages[math_random(1, #murder_messages)]
	msg = string.gsub(msg, "<v>", "<" .. rename.gpn(victim) .. ">")
	msg = string.gsub(msg, "<k>", "<" .. rename.gpn(killer) .. ">")

	local ksex = skins.get_gender_strings(killer)
	local vsex = skins.get_gender_strings(victim)

	msg = string.gsub(msg, "<k_himself>", ksex.himself)
	msg = string.gsub(msg, "<k_his>", ksex.his)

	msg = string.gsub(msg, "<v_himself>", vsex.himself)
	msg = string.gsub(msg, "<v_his>", vsex.his)
	msg = string.gsub(msg, "<v_him>", vsex.him)
	msg = string.gsub(msg, "<v_he>", vsex.he)

	if string.find(msg, "<w>") then
		local hitter = minetest.get_player_by_name(killer)
		if hitter then
			local wield = hitter:get_wielded_item()
			local def = minetest.registered_items[wield:get_name()]
			local meta = wield:get_meta()
			local description = meta:get_string("description")
			if description ~= "" then
				msg = string.gsub(msg, "<w>", "'" .. utility.get_short_desc(description):trim() .. "'")
			elseif def and def.description then
				local str = utility.get_short_desc(def.description)
				if str == "" then
					str = "Potato Fist"
				end
				msg = string.gsub(msg, "<w>", str)
			end
		end
	end

	if type(sendto) == "string" then
		minetest.chat_send_player(sendto, "# Server: " .. msg)
	else
		minetest.chat_send_all("# Server: " .. msg)
	end
end



function city_block.hit_possible(p1pos, p2pos)
	-- Range limit, stops hackers with long reach.
	if vector_distance(p1pos, p2pos) > 6 then
		return false
	end

	-- Cannot attack through walls.
	-- But if node wouldn't stop an arrow, keep testing the line.
	--local raycast = minetest.raycast(p1pos, p2pos, false, false)

	-- This seems to cause random freezes and 100% CPU.
	--[[
	local los, pstop = minetest.line_of_sight(p1pos, p2pos)
	while not los do
		if throwing.node_blocks_arrow(minetest.get_node(vector_round(pstop)).name) then
			return false
		end
		local dir = vector.direction(pstop, p2pos)
		local ns = vector.add(pstop, dir)
		los, pstop = minetest.line_of_sight(ns, p2pos)
	end
	--]]

	return true
end



function city_block.send_to_jail(victim_pname, attack_pname)
	-- Killers don't go to jail if the victim is a registered cheater.
	if not sheriff.is_cheater(victim_pname) then
		local hitter = minetest.get_player_by_name(attack_pname)
		if hitter and jail.go_to_jail(hitter, nil) then
			minetest.chat_send_all(
				"# Server: Criminal <" .. rename.gpn(attack_pname) .. "> was sent to gaol for " ..
				city_block:get_adjective() .. " <" .. rename.gpn(victim_pname) .. "> within city limits.")
		end
	end
end



function city_block.handle_assassination(p2pos, victim_pname, attack_pname, melee)
	-- Bed position is only lost if player died outside city to a melee weapon.
	if not city_block:in_safebed_zone(p2pos) and melee then
		-- Victim doesn't lose their bed respawn if they were killed by a cheater.
		if not sheriff.is_cheater(attack_pname) then
			minetest.chat_send_player(victim_pname, "# Server: Your bed is lost! You were assassinated in the wilds.")
			beds.clear_player_spawn(victim_pname)
		end
	end
end



function city_block.handle_consequences(player, hitter, damage, melee)
	local victim_pname = player:get_player_name()
	local attack_pname = hitter:get_player_name()
	local time = os.time()
	local hp = player:get_hp()
	local p2pos = utility.get_head_pos(player:get_pos())
	local vpos = vector_round(p2pos)

	city_block.attackers[victim_pname] = attack_pname
	city_block.victims[victim_pname] = time

	if not (hp > 0 and (hp - damage) <= 0) then
		return
	end

	default.detach_player_if_attached(player)
	city_block.murder_message(attack_pname, victim_pname)

	if city_block:in_city(p2pos) then
		local t0 = city_block.victims[attack_pname] or time
		local tdiff = (time - t0)

		if not city_block.attackers[attack_pname] then
			city_block.attackers[attack_pname] = ""
		end

		--[[
			Behavior Table (obtained through testing):

			In city-block area, no protection:
				A kills B, B did not retaliate -> A goes to jail
				A kills B, B had retaliated    -> Nobody jailed
				(The table is the same if A and B are inverted)

			In city-block area, protected by A (with nearby jail available):
				A kills B, B did not retaliate -> A goes to jail
				A kills B, B had retaliated    -> Nobody jailed
				B kills A, A did not retaliate -> B goes to jail
				B kills A, A had retaliated    -> B goes to jail
				(The table is the same if A and B are inverted, and protection is B's)

			Notes:
				A hit from A or B is considered retaliation if it happens very soon
				after the other player hit. Thus, if both A and B are hitting, then both
				are considered to be retaliating -- in that case, land ownership is used
				to resolve who should go to jail.

				It does not matter who hits first in a fight -- only who kills the other
				player first.

				If there is no jail available for a crook to be sent to, then nothing
				happens in any case, regardless of who wins the fight or owns the land.

		--]]

		-- Victim is "landowner" if area is protected, but they have access.
		local landowner = (minetest.test_protection(vpos, "") and
			not minetest.test_protection(vpos, victim_pname))

		-- Killing justified after provocation, but not if victim owns the land.
		if city_block.attackers[attack_pname] == victim_pname and
				tdiff < 30 and not landowner then
			return
		else
			-- Go to jail! Do not pass Go. Do not collect $200.
			city_block.send_to_jail(victim_pname, attack_pname)
		end
	else
		-- Player killed outside town.
		-- This only does something if the attack was with a melee weapon!
		city_block.handle_assassination(p2pos, victim_pname, attack_pname, melee)
	end
end



city_block.attackers = city_block.attackers or {}
city_block.victims = city_block.victims or {}

-- Return `true' to prevent the default damage mechanism.
-- Note: player is sometimes the hitter (player punches self). This is sometimes
-- necessary when a mod needs to punch a player, but has no entity that can do
-- the actual punch.
function city_block.on_punchplayer(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if not player:is_player() then
		return
	end

	local melee_hit = true
	if tool_capabilities.damage_groups.from_arrow then
		-- Someone launched this weapon. The hitter is most likely the nearest
		-- player that isn't the player going to be hit.
		melee_hit = false

		-- We don't have enough information to know exactly who fired this weapon,
		-- but it's probably a safe bet that it was the nearest player who is NOT
		-- the player being hit. But if we were explicitly provided a player object
		-- that is NOT self, then we don't need to do this.
		if hitter == player or not hitter:is_player() then
			-- If initial hitter is the player, or the hitter isn't a player, then
			-- get the nearest other player to this position (who is not the initial
			-- player) and use that player as the hitter.

			local pos = player:get_pos()
			local culprit = hb4.nearest_player_not(pos, player)
			if culprit then
				local cpos = culprit:get_pos()
				-- Only if culprit is nearby.
				if vector.distance(cpos, pos) < 50 then
					hitter = culprit
				end
			end
		end
	end
	
	if not hitter:is_player() then
		return
	end

	-- Random accidents happen to punished players during PvP.
	do
		local attacker = hitter:get_player_name()
		if sheriff.is_cheater(attacker) then
			if sheriff.punish_probability(attacker) then
				sheriff.punish_player(attacker)
			end
		end
	end

	local p1pos = utility.get_head_pos(hitter:get_pos())
	local p2pos = utility.get_head_pos(player:get_pos())

	-- Check if hit is physically possible (range, blockage, etc).
	if melee_hit and not city_block.hit_possible(p1pos, p2pos) then
		return true
	end

	-- PvP is disabled for players in jail. This fixes a possible way to exploit jail.
	if jail.is_player_in_jail(hitter) or jail.is_player_in_jail(player) then
		minetest.chat_send_player(hitter:get_player_name(), "# Server: Brawling is not allowed in jail.")
		return true
	end

	-- Admins cannot be punched.
	if gdac.player_is_admin(player) then
		return true
	end

	-- Let others hear sounds of nearby combat.
	if damage > 0 then
		ambiance.sound_play("player_damage", p2pos, 2.0, 30)
	end

	-- If hitter is self, punch was (most likely) due to game code.
	if player == hitter then
		return
	end

	-- Stuff that happens when one player kills another.
	city_block.handle_consequences(player, hitter, damage, melee_hit)
end

